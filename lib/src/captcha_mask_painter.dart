import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A painter that draws random colored mask lines over the captcha text.
///
/// The mask lines make the text harder for bots to recognize while staying
/// readable for humans.
class CaptchaMaskPainter extends CustomPainter {
  /// Creates a mask painter that draws up to [lineCount] mask lines using
  /// the given [_colors].
  CaptchaMaskPainter(
    this._colors, {
    this.lineCount = 5,
    this.padding = 10.0,
    this.seed,
  }) : _paint = Paint()..strokeWidth = 3;

  final Paint _paint;

  /// The colors used for the random mask lines.
  ///
  /// When `null` or empty, no mask lines are drawn.
  final List<Color>? _colors;

  /// The number of mask lines to draw over the text.
  final int lineCount;

  /// The vertical padding that keeps mask lines away from top and bottom edges.
  final double padding;

  /// Optional seed to make line generation deterministic for a given instance.
  final int? seed;

  @override
  void paint(Canvas canvas, Size size) {
    final colors = _colors;
    if (colors == null || colors.isEmpty || lineCount <= 0) {
      return;
    }

    final random = seed != null ? Random(seed) : Random();
    for (var i = 0; i < lineCount; i++) {
      _drawRandomLine(canvas, size, colors, random);
    }
  }

  void _drawRandomLine(Canvas canvas, Size size, List<Color> colors, Random random) {
    _paint.color = colors[random.nextInt(colors.length)];
    final availableHeight = size.height - 2 * padding;
    final y = availableHeight > 0
        ? padding + random.nextDouble() * availableHeight
        : padding;
    final x = random.nextDouble() * (size.width / 2);
    final w = random.nextDouble() * size.width;
    final h = 1.0 + random.nextDouble() * 3.0;

    canvas.drawRect(
      Rect.fromLTWH(x, y, w, h),
      _paint,
    );
  }

  @override
  bool shouldRepaint(covariant CaptchaMaskPainter oldDelegate) {
    return !listEquals(oldDelegate._colors, _colors) ||
        oldDelegate.lineCount != lineCount ||
        oldDelegate.padding != padding ||
        oldDelegate.seed != seed;
  }
}
