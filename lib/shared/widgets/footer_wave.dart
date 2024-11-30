import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class WaveFooter extends StatelessWidget {
  final double height;
  const WaveFooter({
    required this.height,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: height,
      child: CustomPaint(
        painter: _Wave(),
      ),
    );
  }
}

class _Wave extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final lapiz = Paint()
      ..color = AppTheme.mainColor
      ..style = PaintingStyle.fill
      ..strokeWidth = 20;

    final path = Path()
      ..moveTo(
        0,
        size.height,
      )
      ..lineTo(0, size.height * 0.5)
      ..quadraticBezierTo(
        size.width * 0.15,
        size.height * 0.7,
        size.width * 0.3,
        size.height * 0.5,
      )
      ..quadraticBezierTo(
        size.width * 0.6,
        0,
        size.width,
        40,
      )
      ..lineTo(size.width, size.height);

    canvas.drawPath(
      path,
      lapiz,
    );

    // lapiz.color = Colors.black;
    // final point = Offset(
    //   size.width * 0.75,
    //   size.height * 0.1,
    // );
    // canvas.drawPoints(PointMode.points, [point], lapiz);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
