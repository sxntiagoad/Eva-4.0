import 'package:flutter/material.dart';
import '../../../models/week.dart';
import 'health_day_indicator.dart';

class HealthQuestionItem extends StatelessWidget {
  final String questionId;
  final String questionText;
  final Week weekData;
  final Function(String, bool?)? onDayChange;

  const HealthQuestionItem({
    required this.questionId,
    required this.questionText,
    required this.weekData,
    this.onDayChange,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              questionText,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDay('L', 'Lunes', weekData.lunes),
                  _buildDay('M', 'Martes', weekData.martes),
                  _buildDay('M', 'Miercoles', weekData.miercoles),
                  _buildDay('J', 'Jueves', weekData.jueves),
                  _buildDay('V', 'Viernes', weekData.viernes),
                  _buildDay('S', 'Sabado', weekData.sabado),
                  _buildDay('D', 'Domingo', weekData.domingo),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDay(String label, String dayName, bool? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: HealthDayIndicator(
        label: label,
        dayName: dayName,
        value: value,
        onChange: onDayChange,
      ),
    );
  }
}