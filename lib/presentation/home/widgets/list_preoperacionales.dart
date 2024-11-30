import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/preoperacionales_provider.dart';
import 'preoperacionales_card.dart';

class ListPreoperacionales extends ConsumerWidget {
  const ListPreoperacionales({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allPreoperaciones = ref.watch(allPreoperacionalesProvider);
    return allPreoperaciones.when(
      data: (data) => ListView.builder(
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
    );
  }
}
