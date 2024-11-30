import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/preoperacionales_provider.dart';
import '../../home/widgets/preoperacionales_card.dart';

class ListPreoperacionalesScreen extends ConsumerWidget {
  static const name = 'list-preoperacionales-screen';
  const ListPreoperacionalesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allPreoperaciones = ref.watch(allPreoperacionalesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Preoperacionales')),
      body: allPreoperaciones.when(
        data: (data) => data.isEmpty 
          ? const Center(
              child: Text('No hay preoperacionales abiertos',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                if (index == data.length - 1) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 200),
                    child: PreoperacionalesCard(
                      preoperacional: data[index],
                    ),
                  );
                }
                return PreoperacionalesCard(
                  preoperacional: data[index],
                );
              },
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
