import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A painter that draws random colored smooth curves over the captcha text.
///
/// The mask curves make the text harder for bots to recognize while staying
/// readable and clean for humans without overly obscuring characters.
class CaptchaMaskPainter extends CustomPainter {
  /// Creates a mask painter that draws up to [lineCount] mask curves using
  /// the given [_colors].
  CaptchaMaskPainter(
    this._colors, {
    this.lineCount = 4,
    this.padding = 8.0,
    this.seed,
  }) : _paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

  final Paint _paint;

  /// The colors used for the random mask curves.
  ///
  /// When `null` or empty, no mask curves are drawn.
  final List<Color>? _colors;

  /// The number of mask curves to draw over the text.
  final int lineCount;

  /// The vertical padding that keeps mask curves away from top and bottom edges.
  final double padding;

  /// Optional seed to make curve generation deterministic for a given instance.
  final int? seed;

  @override
  void paint(Canvas canvas, Size size) {
    final colors = _colors;
    if (colors == null || colors.isEmpty || lineCount <= 0) {
      return;
    }

    final random = seed != null ? Random(seed) : Random();
    for (var i = 0; i < lineCount; i++) {
      _drawRandomCurve(canvas, size, colors, random);
    }
  }

  void _drawRandomCurve(Canvas canvas, Size size, List<Color> colors, Random random) {
    _paint.color = colors[random.nextInt(colors.length)].withValues(alpha: 0.55);
    _paint.strokeWidth = 1.0 + random.nextDouble() * 0.8; // Thin, elegant curves (1.0 - 1.8 px)

    final path = Path();
    
    // Start point on the left edge
    final startY = padding + random.nextDouble() * (size.height - 2 * padding);
    path.moveTo(0, startY);

    // Control points for a smooth, natural wave curve flowing across the text path
    final cp1x = size.width * 0.3 + random.nextDouble() * (size.width * 0.15);
    final cp1y = padding + random.nextDouble() * (size.height - 2 * padding);

    final cp2x = size.width * 0.6 + random.nextDouble() * (size.width * 0.15);
    final cp2y = padding + random.nextDouble() * (size.height - 2 * padding);

    final endX = size.width;
    final endY = padding + random.nextDouble() * (size.height - 2 * padding);

    path.cubicTo(cp1x, cp1y, cp2x, cp2y, endX, endY);

    canvas.drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(covariant CaptchaMaskPainter oldDelegate) {
    return !listEquals(oldDelegate._colors, _colors) ||
        oldDelegate.lineCount != lineCount ||
        oldDelegate.padding != padding ||
        oldDelegate.seed != seed;
  }
}
