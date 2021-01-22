library captcha;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'captcha_mask_painter.dart';

class Captcha extends StatelessWidget {
  final double width, height;
  final Color backgroundColor;
  final String text;
  final TextStyle style;
  final List<Color> lineColors;
  final BoxDecoration decoration;
  static List<Color> rainbowColors = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.cyan,
    Colors.blue,
    Colors.purple
  ];

  Random _random = Random();

  Captcha(
      {Key key,
      this.width = double.infinity,
      this.height = 40,
      this.backgroundColor = Colors.white,
      this.style = const TextStyle(fontSize: 18),
      this.text = '',
      this.lineColors,
      this.decoration = const BoxDecoration(
        color: Colors.white,
      )}) : super(key: key);

  static String generateText(
      {int length = 4, bool withNumber = true, bool withLetter = true}) {
    var r = Random();
    String out = '';
    for (var i = 0; i < length; i++) {
      String gen = '';
      if (withLetter && withNumber) {
        gen = r.nextBool() ? _genLetter(r) : _genNumber(r);
      } else if (withLetter && !withNumber) {
        gen = _genLetter(r);
      } else if (!withLetter && withNumber) {
        gen = _genNumber(r);
      }
      out += gen;
    }
    return out;
  }

  static String _genNumber(Random r) {
    return r.nextInt(10).toString();
  }

  static String _genLetter(Random r) {
    if (r.nextBool()) {
      //65-90 A-Z
      return String.fromCharCode((r.nextInt(90 - 65 + 1) + 65));
    } else {
      //97-122 a-z
      return String.fromCharCode(r.nextInt(122 - 97 + 1) + 97);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: decoration,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: text.characters.map((e) => _getText(e)).toList(),
          ),
          CustomPaint(
            size: Size(width, height),
            painter: CaptchaMaskPainter(lineColors),
          )
        ],
      ),
    );
  }

  Widget _getText(String text) {
    double skewX =
        _random.nextInt(8).toDouble() / 10 * (_random.nextBool() ? -1 : 1);
    double skewY = _random.nextInt(8).toDouble() / 10 * (skewX > 0 ? -1 : 1);
    print('${_random.nextDouble()}');
    return Transform(
      transform: Matrix4.skew(skewX, skewY),
      child: Text(
        text,
        style: style,
      ),
    );
  }
}
