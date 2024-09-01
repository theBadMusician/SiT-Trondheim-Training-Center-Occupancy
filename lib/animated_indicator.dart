import 'dart:math';
import 'package:flutter/material.dart';

/*Custom painter to draw a red dot on the graph.*/
class IndicatorPainter extends CustomPainter {
  final double y;
  final double maxHeight;
  IndicatorPainter(this.y, this.maxHeight);

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
    double length = maxHeight - y; // Length of the line. Default to 100.0 if y is null
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

/*A widget that animates the position of a red dot using implicit animations.*/
class AnimatedIndicator extends ImplicitlyAnimatedWidget {
  /// The x-coordinate of the red dot.
  final double x;

  /// The y-coordinate of the red dot.
  final double y;

  /// The max height for the frame.
  final double maxHeight;

  /// Creates an [AnimatedIndicator] widget.
  ///
  /// The [x] and [y] coordinates determine the position of the red dot,
  /// and it animates between old and new positions whenever they change.
  const AnimatedIndicator({
    super.key,
    required this.x,
    required this.y,
    required this.maxHeight,
    super.duration = const Duration(milliseconds: 150),
    super.curve,
  });

  @override
  AnimatedIndicatorState createState() => AnimatedIndicatorState();
}

class AnimatedIndicatorState extends AnimatedWidgetBaseState<AnimatedIndicator> {
  /// Tween for animating the x-coordinate.
  Tween<double>? _xTween;

  /// Tween for animating the y-coordinate.
  Tween<double>? _yTween;

  @override
  Widget build(BuildContext context) {
    // Calculate the current x and y positions using the tweens and animation.
    final currentX = _xTween?.evaluate(animation) ?? widget.x;
    final currentY = _yTween?.evaluate(animation) ?? widget.y;
    return Positioned(
      left: currentX,
      top: currentY,
      child: CustomPaint(
        painter: IndicatorPainter(currentY, widget.maxHeight - 16),
      ),
    );
  }

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    // Create or update the x and y tweens.
    _xTween = visitor(
      _xTween,
      widget.x,
      (dynamic value) => Tween<double>(begin: value as double),
    ) as Tween<double>?;

    _yTween = visitor(
      _yTween,
      widget.y,
      (dynamic value) => Tween<double>(begin: value as double),
    ) as Tween<double>?;
  }
}
