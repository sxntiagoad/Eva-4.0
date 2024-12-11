import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../providers/new_preoperacional_provider.dart';

class DateField extends ConsumerStatefulWidget {
  final String label;
  final IconData icon;

  const DateField({
    super.key,
    required this.label,
    required this.icon,
  });

  @override
  DateFieldState createState() => DateFieldState();
}

class DateFieldState extends ConsumerState<DateField> {
  late Timestamp? currentValue;

  @override
  void initState() {
    super.initState();
    currentValue = ref.read(newPreoperacionalProvider).extracto; // Obtener el valor inicial
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: ElevatedButton.icon(
        onPressed: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: currentValue?.toDate() ?? DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            currentValue = Timestamp.fromDate(picked);
            ref.read(newPreoperacionalProvider.notifier).updateExtracto(currentValue!);
            setState(() {}); // Actualizar el estado para reflejar el cambio
          }
        },
        icon: Icon(widget.icon),
        label: Text(
          currentValue != null
              ? '${widget.label}: ${DateFormat('dd/MM/yyyy').format(currentValue!.toDate())}'
              : 'Seleccionar Fecha de ${widget.label}',
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          alignment: Alignment.centerLeft,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
