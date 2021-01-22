
import 'dart:ui';

import 'package:flutter/material.dart';

class CaptchaPainter extends CustomPainter{

  Paint _paint;

  CaptchaPainter(){
    _paint = Paint()
        ..color = Colors.white;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), _paint);
  }

  @override
    bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

}