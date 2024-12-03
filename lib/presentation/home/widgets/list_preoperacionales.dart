import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/preoperacionales_provider.dart';
import 'preoperacionales_card.dart';

class ListPreoperacionales extends ConsumerStatefulWidget {
  const ListPreoperacionales({super.key});

  @override
  ConsumerState<ListPreoperacionales> createState() => _ListPreoperacionalesState();
}

class _ListPreoperacionalesState extends ConsumerState<ListPreoperacionales> {
  @override
  void initState() {
    super.initState();
    // Invalida el provider para recargar los datos al entrar a la página
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(allPreoperacionalesProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final allPreoperacionesAsync = ref.watch(allPreoperacionalesProvider);

    return allPreoperacionesAsync.when(
      data: (preoperacionales) => ListView.builder(
        itemCount: preoperacionales.length,
        itemBuilder: (context, index) {
          if (index == preoperacionales.length - 1) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 200),
              child: PreoperacionalesCard(
                preoperacional: preoperacionales[index],
              ),
            );
          }
          return PreoperacionalesCard(
            preoperacional: preoperacionales[index],
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}
