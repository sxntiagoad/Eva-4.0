import 'package:flutter/material.dart';
import '../../../models/health_report.dart';
import '../../../models/week.dart';
import 'health_question_item.dart';

class HealthCardCategory extends StatelessWidget {
  final Map<String, Week> questions;
  final Map<String, String> questionTexts;
  final Function(String, String, bool?)? onDayUpdate;

  const HealthCardCategory({
    required this.questions,
    required this.questionTexts,
    this.onDayUpdate,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: questions.length,
      itemBuilder: (context, index) {
        final questionId = questions.keys.elementAt(index);
        final weekData = questions[questionId]!;
        final questionText = questionTexts[questionId] ?? '';

        return HealthQuestionItem(
          questionId: questionId,
          questionText: questionText,
          weekData: weekData,
          onDayChange: onDayUpdate != null 
            ? (day, value) => onDayUpdate!(questionId, day, value)
            : null,
        );
      },
    );
  }
}