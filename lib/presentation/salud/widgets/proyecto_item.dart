import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eva/models/health_report.dart';
import 'package:eva/providers/salud/health_db_provider.dart';
import 'package:eva/presentation/salud/services/options_provider.dart';

class ProyectoItem extends ConsumerWidget {
  final HealthReport healthReport;
  final Function(String) onSelectedValueUpdate;

  ProyectoItem({required this.healthReport, required this.onSelectedValueUpdate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final optionsAsyncValue = ref.watch(optionsProvider);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selecciona una opción:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            optionsAsyncValue.when(
              data: (options) => DropdownButtonFormField<String>(
                value: healthReport.selectedValue.isEmpty ? null : healthReport.selectedValue,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: const Color.fromARGB(255, 255, 255, 255),
                ),
                hint: const Text('Selecciona una opción'),
                items: options.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    print('Nuevo valor seleccionado: $newValue');
                    onSelectedValueUpdate(newValue);
                  }
                },
              ),
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error: $error'),
            ),
          ],
        ),
      ),
    );
  }
}
