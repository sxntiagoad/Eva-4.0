import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../providers/preoperacional_db_provider.dart';

class PreoperacionalDateField extends ConsumerWidget {
  final String label;
  final IconData icon;

  const PreoperacionalDateField({
    Key? key,
    required this.label,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preoperacional = ref.watch(preoperacionalDbProvider);
    Timestamp? currentValue = preoperacional.extracto;

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
            ref.read(preoperacionalDbProvider.notifier).updateExtracto(currentValue!);
          }
        },
        icon: Icon(icon),
        label: Text(
          currentValue != null
              ? '$label: ${DateFormat('dd/MM/yyyy').format(currentValue!.toDate())}'
              : 'Seleccionar Fecha de $label',
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