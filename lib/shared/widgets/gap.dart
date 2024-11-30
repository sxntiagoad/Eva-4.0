import 'package:flutter/material.dart';

class Gap extends StatelessWidget {
  final double size;

  const Gap(
    this.size, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isInRow = context.findAncestorWidgetOfExactType<Row>() != null;
    final isInColumn = context.findAncestorWidgetOfExactType<Column>() != null;
   

    return SizedBox(
      height: isInColumn ? size : null,
      width: isInRow ? size : null,
    );
  }
}
