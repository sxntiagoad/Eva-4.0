import 'package:eva/presentation/salud/widgets/health_card.dart';
import 'package:eva/providers/salud/health_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ListHealthScreen extends ConsumerWidget {
  static const name = 'list-health-screen';
  const ListHealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allHealthRecords = ref.watch(allHealthProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Registros de Salud')),
      body: allHealthRecords.when(
        data: (data) => data.isEmpty
            ? const Center(
                child: Text(
                  'No hay registros de salud abiertos',
                  style: TextStyle(fontSize: 16),
                ),
              )
            : ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  if (index == data.length - 1) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 200),
                      child: HealthCard(
                        healthReport: data[
                            index], // Asegúrate de que data[index] sea de tipo HealthReport
                      ),
                    );
                  }
                  return HealthCard(
                    healthReport: data[
                        index], // Asegúrate de que data[index] sea de tipo HealthReport
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
