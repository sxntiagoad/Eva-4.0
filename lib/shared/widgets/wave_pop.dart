
import 'package:eva/shared/widgets/wave_header.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WavePop extends StatelessWidget {
  const WavePop({
    super.key,
    required this.topPadding,
  });

  final double topPadding;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const WaveHeader(),
        Positioned(
          top: topPadding + 10,
          left: 16,
          child: OutlinedButton(
            onPressed: () {
              context.pop();
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(
                  color: Colors.white, width: 3),
            ),
            child: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}