
import 'package:flutter/widgets.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../models/week.dart';
import 'sub_category_item.dart';

class CardCategory extends StatelessWidget {
  final String categoryKey;
  final Map<String, Week> subItem;
  const CardCategory({
    required this.categoryKey,
    required this.subItem,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.mainColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            categoryKey,
            style: AppTheme.titleStyleOp(),
          ),
          ...subItem.entries.map(
            (subCategoy) => SubCategoryItem(
              categoryKey: categoryKey,
              subCategoryKey: subCategoy.key,
              week: subCategoy.value,
            ),
          ),
        ],
      ),
    );
  }
}
