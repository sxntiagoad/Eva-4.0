import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/week.dart';
import '../../../providers/limpieza/new_limpieza_provider.dart';
import 'category_item.dart';

class ListCategory extends ConsumerWidget {
  // Instrucciones como constante estática
  static const Map<String, String> _instructions = {
    'ASIENTO CONDUCTOR': 'Limpiar y desinfectar',
    'ASIENTO PASAJERO': 'Limpiar y desinfectar',
    'SALPICADERO': 'Limpiar y desinfectar',
    'PALANCA DE CAMBIOS': 'Limpiar y desinfectar',
    'VENTILACIÓN': 'Limpiar y desinfectar',
    'CINTURON DE SEGURIDAD': 'Revisar funcionamiento y limpiar',
    'TAPETE': 'Sacudir y limpiar',
    'PANEL DE MANDOS': 'Limpiar con cuidado',
    'ESPEJO': 'Limpiar y verificar ajuste',
    'MANIJA EXTERNA PUERTA DE CONDUCTOR': 'Limpiar y desinfectar',
    'MANIJA INTERNA PUERTA DE CONDUCTOR': 'Limpiar y desinfectar',
    'MANIJAS EXTERNAS PUERTAS DE PASAJERO': 'Limpiar y desinfectar',
    'MANIJAS INTERNAS PUERTAS DE PASAJERO': 'Limpiar y desinfectar',
    'VOLANTE': 'Limpiar y desinfectar',
  };

  final Map<String, Week>? inspecciones;
  final Function(String category, String day, bool? value)? onUpdateInspeccion;

  const ListCategory({
    super.key,
    this.inspecciones,
    this.onUpdateInspeccion,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inspeccionesData = inspecciones ?? ref.watch(newLimpiezaProvider).inspecciones;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final category = inspeccionesData.keys.elementAt(index);
          final weekData = inspeccionesData[category]!;
          final instruction = _instructions[category] ?? '';

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: CategoryItem(
              title: category,
              instruction: instruction,
              weekData: weekData,
              onDayChange: (day, value) {
                // Capitalizar la primera letra del día
                final capitalizedDay = day[0].toUpperCase() + day.substring(1);
                
                if (onUpdateInspeccion != null) {
                  onUpdateInspeccion!(category, capitalizedDay, value);
                } else {
                  // Si no hay callback externo, usar el provider directamente
                  ref.read(newLimpiezaProvider.notifier).updateDayOfWeek(
                    category,
                    capitalizedDay,
                    value,
                  );
                }
              },
            ),
          );
        },
        childCount: inspeccionesData.length,
      ),
    );
  }
}