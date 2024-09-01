import 'package:flutter/material.dart';

/// Custom painter to draw a red dot on the graph.
class RedDotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    // Draw a red dot at the origin of the canvas
    canvas.drawCircle(Offset.zero, 5, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;  // No need to repaint as the dot is static
  }
}
