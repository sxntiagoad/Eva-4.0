import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/week.dart';
import '../../../../providers/new_preoperacional_provider.dart';
import 'card_category.dart';

class ListCategory extends ConsumerWidget {
  const ListCategory({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newPreoperacional = ref.watch(newPreoperacionalProvider);
    Map<String, Map<String, Week>> inspecciones =
        newPreoperacional.inspecciones;

    return Column(
      children: inspecciones.entries
          .map(
            (category) => CardCategory(
              categoryKey: category.key,
              subItem: category.value,
            ),
          )
          .toList(),
    );
  }
}


