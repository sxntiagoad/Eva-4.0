import 'package:flutter/material.dart';
import '../../../models/week.dart';
import 'day_week.dart';

class CategoryItem extends StatelessWidget {
  final String title;
  final String instruction;
  final Week weekData;
  final Function(String, bool?)? onDayChange;

  const CategoryItem({
    required this.title,
    required this.instruction,
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
            // Título
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Instrucción
            if (instruction.isNotEmpty) ...[
              Text(
                instruction,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Días de la semana
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildDay('L', 'lunes', weekData.lunes),
                  _buildDay('M', 'martes', weekData.martes),
                  _buildDay('X', 'miercoles', weekData.miercoles),
                  _buildDay('J', 'jueves', weekData.jueves),
                  _buildDay('V', 'viernes', weekData.viernes),
                  _buildDay('S', 'sabado', weekData.sabado),
                  _buildDay('D', 'domingo', weekData.domingo),
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
      child: DayWeek(
        label: label,
        dayName: dayName,
        value: value,
        onChange: onDayChange,
      ),
    );
  }
}
