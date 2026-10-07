import 'package:flutter/material.dart';

/// A painter that fills the canvas with a solid background color.
class CaptchaPainter extends CustomPainter {
  /// Creates a painter that fills the canvas with [color].
  CaptchaPainter({this.color = Colors.white})
      : _paint = Paint()..color = color;

  /// The background fill color.
  final Color color;

  final Paint _paint;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, _paint);
  }

  @override
  bool shouldRepaint(covariant CaptchaPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
