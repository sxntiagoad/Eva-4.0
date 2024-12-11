import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AlertsWidget extends ConsumerWidget {
  const AlertsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('cars').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        List<DocumentAlert> alerts = [];
        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final carPlate = data['carPlate'] as String? ?? 'Sin placa';
          
          _checkDocument('SOAT', data['soat'] as Timestamp?, doc.id, carPlate, alerts);
          _checkDocument('Tecnicomecánica', data['tecnicoMec'] as Timestamp?, doc.id, carPlate, alerts);
          _checkDocument('Tarjeta de Operación', data['tarjetaOp'] as Timestamp?, doc.id, carPlate, alerts);
        }

        // Ordenar por días restantes (más urgentes primero)
        alerts.sort((a, b) => a.daysRemaining.compareTo(b.daysRemaining));

        if (alerts.isEmpty) {
          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: colors.outline.withOpacity(0.2)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline, 
                    color: colors.primary.withOpacity(0.7),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Todos los documentos están al día',
                    style: TextStyle(
                      color: colors.onSurface.withOpacity(0.7),
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: colors.outline.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: alerts.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: colors.outline.withOpacity(0.1),
                ),
                itemBuilder: (context, index) {
                  final alert = alerts[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: alert.alertColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.warning_rounded,
                        color: alert.alertColor,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      '${alert.documentType} - ${alert.carPlate}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: Text(
                      '${alert.status} - ${alert.daysRemaining} días',
                      style: TextStyle(color: alert.alertColor),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

void _checkDocument(
  String type,
  Timestamp? date,
  String carId,
  String carPlate,
  List<DocumentAlert> alerts,
) {
  if (date == null) return;

  final DateTime fechaVencimiento = date.toDate();
  final DateTime ahora = DateTime.now();
  
  final DateTime fechaVencimientoSinHora = DateTime(
    fechaVencimiento.year, 
    fechaVencimiento.month, 
    fechaVencimiento.day
  );
  
  final DateTime ahoraSinHora = DateTime(
    ahora.year, 
    ahora.month, 
    ahora.day
  );

  final int diasRestantes = fechaVencimientoSinHora.difference(ahoraSinHora).inDays;

  if (diasRestantes <= 15) {
    alerts.add(DocumentAlert(
      documentType: type,
      daysRemaining: diasRestantes,
      carId: carId,
      carPlate: carPlate,
    ));
  }
}

class DocumentAlert {
  final String documentType;
  final int daysRemaining;
  final String carId;
  final String carPlate;

  DocumentAlert({
    required this.documentType,
    required this.daysRemaining,
    required this.carId,
    required this.carPlate,
  });

  Color get alertColor {
    if (daysRemaining <= 7) return Colors.red;
    if (daysRemaining <= 15) return Colors.orange;
    return Colors.green;
  }

  String get status {
    if (daysRemaining < 0) return 'VENCIDO';
    if (daysRemaining <= 7) return 'PRÓXIMO A VENCER';
    return 'POR VENCER';
  }
}
