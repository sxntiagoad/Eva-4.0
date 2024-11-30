import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/week.dart';
import '../../../../providers/preoperacional_db_provider.dart';

class SubCategoryItemDb extends StatelessWidget {
  final String categoryKey;
  final String subCategoryKey;
  final Week week;

  const SubCategoryItemDb({
    super.key,
    required this.categoryKey,
    required this.subCategoryKey,
    required this.week,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        // border: Border.all(
        //   color: Colors.white,
        // ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            subCategoryKey,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              DayWeek(
                categoryKey: categoryKey,
                subCategoryKey: subCategoryKey,
                day: 'L',
                dayValue: 'Lunes',
                isMarked: week.lunes,
              ),
              DayWeek(
                categoryKey: categoryKey,
                subCategoryKey: subCategoryKey,
                day: 'M',
                dayValue: 'Martes',
                isMarked: week.martes,
              ),
              DayWeek(
                categoryKey: categoryKey,
                subCategoryKey: subCategoryKey,
                day: 'M',
                dayValue: 'Miercoles',
                isMarked: week.miercoles,
              ),
              DayWeek(
                categoryKey: categoryKey,
                subCategoryKey: subCategoryKey,
                day: 'J',
                dayValue: 'Jueves',
                isMarked: week.jueves,
              ),
              DayWeek(
                categoryKey: categoryKey,
                subCategoryKey: subCategoryKey,
                day: 'V',
                dayValue: 'Viernes',
                isMarked: week.viernes,
              ),
              DayWeek(
                categoryKey: categoryKey,
                subCategoryKey: subCategoryKey,
                day: 'S',
                dayValue: 'Sabado',
                isMarked: week.sabado,
              ),
              DayWeek(
                categoryKey: categoryKey,
                subCategoryKey: subCategoryKey,
                day: 'D',
                dayValue: 'Domingo',
                isMarked: week.domingo,
              ),
            ],
          )
        ],
      ),
    );
  }
}

class DayWeek extends ConsumerWidget {
  final String categoryKey;
  final String subCategoryKey;
  final String day;
  final String dayValue;
  final bool? isMarked;
  const DayWeek({
    required this.categoryKey,
    required this.subCategoryKey,
    required this.day,
    required this.dayValue,
    required this.isMarked,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        ref.read(preoperacionalDbProvider.notifier).updateDayOfWeek(
              categoryKey,
              subCategoryKey,
              dayValue,
              nextBoolDay(isMarked),
            );
      },
      child: CircleAvatar(
        radius: 18,
        backgroundColor: _colorDay(isMarked),
        child: Text(
          day,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

bool? nextBoolDay(bool? dayBool) {
  if (dayBool == null) return true;
  if (dayBool == true) return false;
  return null;
}

Color? _colorDay(bool? day) {
  if (day == null) return Colors.grey;
  return day ? Colors.green : Colors.red;
}
