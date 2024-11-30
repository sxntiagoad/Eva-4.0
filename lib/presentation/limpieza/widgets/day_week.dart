import 'package:flutter/material.dart';

class DayWeek extends StatelessWidget {
  final String label;
  final String dayName;
  final bool? value;
  final Function(String, bool?)? onChange;

  const DayWeek({
    required this.label,
    required this.dayName,
    this.value,
    this.onChange,
    super.key,
  });

  void _handleTap() {
    if (onChange == null) return;
    
    final nextValue = value == null ? true : value == true ? false : null;
    onChange!(dayName, nextValue);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _handleTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: value == null ? Colors.grey.shade400 
                : value! ? Colors.green 
                : Colors.red,
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
    );
  }
}