import 'package:eva/presentation/preoperacional/widgets/inspeccion_db/card_category_db.dart';
import 'package:eva/providers/preoperacional_db_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/week.dart';


class ListCategoryDb extends ConsumerWidget {
  const ListCategoryDb({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newPreoperacional = ref.watch(preoperacionalDbProvider);
    Map<String, Map<String, Week>> inspecciones =
        newPreoperacional.inspecciones;

    return Column(
      children: inspecciones.entries
          .map(
            (category) => CardCategoryDb(
              categoryKey: category.key,
              subItem: category.value,
            ),
          )
          .toList(),
    );
  }
}


