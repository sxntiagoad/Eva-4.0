import 'package:flutter/material.dart';

class HealthDayIndicator extends StatelessWidget {
  final String label;
  final String dayName;
  final bool? value;
  final Function(String, bool?)? onChange;

  const HealthDayIndicator({
    required this.label,
    required this.dayName,
    this.value,
    this.onChange,
    super.key,
  });

  void _handleTap() {
    if (onChange == null) return;
    
    // null -> true (bien/verde) -> false (mal/rojo) -> null
    final nextValue = value == null ? true : value == true ? false : null;
    onChange!(dayName, nextValue);
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: _getTooltipMessage(),
      child: InkWell(
        onTap: _handleTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _getColor(),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getColor() {
    if (value == null) return Colors.grey.shade400;
    return value! ? Colors.green : Colors.red;
  }

  String _getTooltipMessage() {
    if (value == null) return '$dayName: Sin respuesta';
    return '$dayName: ${value! ? 'No presenta síntomas' : 'Presenta síntomas'}';
  }
}