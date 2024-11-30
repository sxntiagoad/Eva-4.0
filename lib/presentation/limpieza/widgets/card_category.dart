import 'package:flutter/material.dart';
import '../../../models/week.dart';
import 'category_item.dart';

class CardCategory extends StatelessWidget {
  final Map<String, Week> categories;
  final Map<String, String> instructions;
  final Function(String, String, bool?)? onDayUpdate;

  const CardCategory({
    required this.categories,
    required this.instructions,
    this.onDayUpdate,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories.keys.elementAt(index);
        final weekData = categories[category]!;
        final instruction = instructions[category] ?? '';

        return CategoryItem(
          title: category,
          instruction: instruction,
          weekData: weekData,
          onDayChange: onDayUpdate != null 
            ? (day, value) => onDayUpdate!(category, day, value)
            : null,
        );
      },
    );
  }
}