import 'package:flutter/material.dart';

/// A [CustomPainter] that draws standard football pitch markings.
///
/// Renders the following pitch elements:
/// - Halfway line (horizontal divider at the vertical center)
/// - Center circle (15% of pitch width radius)
/// - Penalty areas (top and bottom) including:
///   - Penalty box (60% width × 16% height)
///   - Goal box (25% width × 6% height)
///   - Penalty arc (semicircle at the edge of the penalty box)
///
/// ## Usage
///
/// ```dart
/// CustomPaint(
///   painter: PitchPainter(color: Colors.white.withOpacity(0.2)),
///   child: ...,
/// )
/// ```
///
/// The [color] parameter controls the stroke color of all markings.
/// Typically set to a semi-transparent white for subtle visibility against
/// the green pitch background.
///
/// This painter uses [PaintingStyle.stroke] with a 1.0 logical pixel width,
/// and does not repaint when the delegate changes (static markings).
class PitchPainter extends CustomPainter {
  /// Creates a pitch painter with the given line [color].
  PitchPainter({required this.color});

  /// The stroke color used for all pitch markings.
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final w = size.width;
    final h = size.height;

    // Halfway Line
    canvas.drawLine(Offset(0, h / 2), Offset(w, h / 2), paint);

    // Center Circle
    canvas.drawCircle(Offset(w / 2, h / 2), w * 0.15, paint);

    // Goal Areas (Top & Bottom)
    _drawGoalArea(canvas, paint, w, h, isTop: true);
    _drawGoalArea(canvas, paint, w, h, isTop: false);
  }

  /// Draws a complete goal area (penalty box + goal box + penalty arc) at
  /// either the top or bottom of the pitch.
  void _drawGoalArea(
    Canvas canvas,
    Paint paint,
    double w,
    double h, {
    required bool isTop,
  }) {
    final penaltyBoxWidth = w * 0.6;
    final penaltyBoxHeight = h * 0.16;
    final penaltyBoxX = (w - penaltyBoxWidth) / 2;
    final penaltyBoxY = isTop ? 0.0 : h - penaltyBoxHeight;

    final goalBoxWidth = w * 0.25;
    final goalBoxHeight = h * 0.06;
    final goalBoxX = (w - goalBoxWidth) / 2;
    final goalBoxY = isTop ? 0.0 : h - goalBoxHeight;

    // Penalty Box
    canvas.drawRect(
      Rect.fromLTWH(
          penaltyBoxX, penaltyBoxY, penaltyBoxWidth, penaltyBoxHeight),
      paint,
    );

    // Goal Box
    canvas.drawRect(
      Rect.fromLTWH(goalBoxX, goalBoxY, goalBoxWidth, goalBoxHeight),
      paint,
    );

    // Penalty Arc
    final arcRect = Rect.fromCircle(
      center: Offset(w / 2, isTop ? penaltyBoxHeight : h - penaltyBoxHeight),
      radius: w * 0.1,
    );
    final double startAngle = isTop ? 0 : 3.14159;
    canvas.drawArc(arcRect, startAngle, 3.14159, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
