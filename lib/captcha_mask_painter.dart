import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class CaptchaMaskPainter extends CustomPainter{

  Paint _paint;
  final List<Color> _colors;
  double padding = 10;


  CaptchaMaskPainter(this._colors){
    _paint = Paint()..strokeWidth = 3;
  }

  @override
  void paint(Canvas canvas, Size size) {
    print('size=$size');
    _paint.color = Colors.red;
    canvas.translate(0, 0);
    // canvas.drawLine(Offset(0,0), Offset(10, 10), _paint);
    for(int i=0;i<5 && _colors!=null && _colors.length > 0;i++){
      _drawRandomLine(canvas, size);
    }
  }

  void _drawRandomLine(Canvas canvas,Size size){
    var r = Random();
    _paint.color = _colors[r.nextInt(_colors.length)];
    var radians = r.nextInt(360)*180/pi;
    // canvas.rotate(radians);
    canvas.drawRect(Rect.fromLTWH(_getRandomDouble(r,size.width/2), _getRandomDouble(r,size.height-2*padding) + padding, _getRandomDouble(r, size.width), _getRandomDouble(r, 4)), _paint);
    // canvas.rotate(-radians);
  }

  double _getRandomDouble(Random r, double max){
    return r.nextInt(max.toInt()).toDouble();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

}