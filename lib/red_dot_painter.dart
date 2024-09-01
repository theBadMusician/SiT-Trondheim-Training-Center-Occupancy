import 'dart:math';

import 'package:flutter/material.dart';

/// Custom painter to draw a red dot on the graph.
class RedDotPainter extends CustomPainter {
  final double y;
  RedDotPainter(this.y);

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    // Draw a red dot at the origin of the canvas
    canvas.drawCircle(Offset.zero, 10, dotPaint);

    // Define the paint for the line
    final linePaint = Paint()
      ..color = Colors.red // Set the color of the line
      ..strokeWidth = 5.0 // Set the thickness of the line
      ..style = PaintingStyle.stroke; // Ensure the line is drawn as a stroke

    // Define the direction and length for the line
    double dir = pi / 2; // Direction in radians (pi radians = 180 degrees)
    double length = y ?? 100.0; // Length of the line. Default to 100.0 if y is null
    // Start point at the origin (center of the dot)
    Offset startPoint = Offset.zero;

    // Calculate the end point using the direction and length
    Offset endPoint = Offset.fromDirection(dir, length);

    // Draw the line from start point to end point
    canvas.drawLine(startPoint, endPoint, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Not repaint as the dot is static or repaint if dynamic
  }
}
