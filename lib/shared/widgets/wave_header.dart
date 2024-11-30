import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class WaveHeader extends StatelessWidget {
  const WaveHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 300,
      child: CustomPaint(
        painter: _Wave(),
      ),
    );
  }
}

class _Wave extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final lapiz2 = Paint()
      ..color = const Color(0xff97BFF6)
      ..style = PaintingStyle.fill
      ..strokeWidth = 20;

    final path2 = Path()
      ..lineTo(
        0,
        size.height * 0.9,
      )
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height + 20,
        size.width * 0.5,
        size.height * 0.90,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.75,
        size.width,
        size.height + 20,
      )
      ..lineTo(
        size.width,
        0,
      );

    canvas.drawPath(
      path2,
      lapiz2,
    );

    final lapiz = Paint()
      ..color = AppTheme.mainColor
      ..style = PaintingStyle.fill
      ..strokeWidth = 20;

    final path = Path()
      ..lineTo(
        0,
        size.height * 0.80,
      )
      ..quadraticBezierTo(
        size.width * 0.30,
        size.height * 0.85,
        size.width * 0.5,
        size.height * 0.60,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.30,
        size.width,
        size.height * 0.60,
      )
      ..lineTo(
        size.width,
        0,
      );

    canvas.drawPath(
      path,
      lapiz,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
