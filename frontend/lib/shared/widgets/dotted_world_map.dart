import 'dart:math' as math;
import 'package:flutter/material.dart';

class DottedWorldMapPainter extends CustomPainter {
  final Color dotColor;

  DottedWorldMapPainter({required this.dotColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    final double dotRadius = 2.4;
    final double step = 11.0;

    final int cols = (size.width / step).floor();
    final int rows = (size.height / step).floor();

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final double x = c * step + step / 2;
        final double y = r * step + step / 2;

        // Normalized 0..1 coordinates
        final double nx = x / size.width;
        final double ny = y / size.height;

        if (_isInContinent(nx, ny)) {
          // Add subtle size/opacity variation for aesthetic depth
          final double distFromCenter =
              math.sqrt(math.pow(nx - 0.5, 2) + math.pow(ny - 0.45, 2));
          final double opacity = (0.35 + 0.45 * (1 - distFromCenter)).clamp(0.2, 0.85);

          paint.color = dotColor.withOpacity(opacity);
          canvas.drawCircle(Offset(x, y), dotRadius, paint);
        }
      }
    }
  }

  // Approximation of world landmasses for dotted effect
  bool _isInContinent(double x, double y) {
    // North America
    if (x >= 0.10 && x <= 0.35 && y >= 0.12 && y <= 0.42) {
      if (x < 0.22 && y > 0.35) return false; // Gulf
      return true;
    }
    // South America
    if (x >= 0.25 && x <= 0.38 && y >= 0.44 && y <= 0.78) {
      if (x > 0.34 && y > 0.65) return false;
      return true;
    }
    // Europe
    if (x >= 0.45 && x <= 0.60 && y >= 0.12 && y <= 0.32) {
      return true;
    }
    // Africa
    if (x >= 0.44 && x <= 0.62 && y >= 0.33 && y <= 0.72) {
      if (x > 0.58 && y > 0.55) return false;
      return true;
    }
    // Asia
    if (x >= 0.58 && x <= 0.88 && y >= 0.10 && y <= 0.50) {
      if (x > 0.78 && y > 0.45) return false;
      return true;
    }
    // Australia
    if (x >= 0.76 && x <= 0.90 && y >= 0.60 && y <= 0.82) {
      return true;
    }
    return false;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DottedWorldMapBackground extends StatelessWidget {
  final Widget? child;

  const DottedWorldMapBackground({Key? key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF5A65AB),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: DottedWorldMapPainter(
                dotColor: Colors.white.withOpacity(0.6),
              ),
            ),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}
