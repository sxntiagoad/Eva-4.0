import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/health_report.dart';
import 'health_card_category.dart';

class HealthQuestionsList extends StatelessWidget {
  final HealthReport healthReport;
  final Function(String, String, bool?)? onAnswerUpdate;

  const HealthQuestionsList({
    required this.healthReport,
    this.onAnswerUpdate,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      sliver: SliverToBoxAdapter(
        child: HealthCardCategory(
          questions: healthReport.questions,
          questionTexts: HealthReport.questionsList,
          onDayUpdate: onAnswerUpdate,
        ),
      ),
    );
  }
}