import 'dart:math';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 拼图验证页面
class SlideVerifyView extends StatefulWidget {
  final int width;

  const SlideVerifyView({Key key, this.width = 300}) : super(key: key);

  @override
  _SlideVerifyViewState createState() => _SlideVerifyViewState();
}

class _SlideVerifyViewState extends State<SlideVerifyView> {
  @override
  void initState() {
    super.initState();
    _futureBuilder = _init(widget.width);
  }

  Future _futureBuilder;

  Future _init(int puzzleWidth) async {
    Random r = Random();

    int puzzleHeight = (puzzleWidth * 0.7).toInt();
    int blockSize = puzzleWidth ~/ 6;
    Offset randomOffset = Offset(
        (r.nextInt(puzzleWidth ~/ 2) + blockSize).toDouble(),
        (r.nextInt(puzzleHeight ~/ 2) + 10).toDouble());
    return [
      await _load(
        'packages/captcha_view/assets/images/3.0x/ic_puzzle.png',
        targetWidth: blockSize,
        targetHeight: blockSize,
      ),
      await _load('packages/captcha_view/assets/images/3.0x/ic_verify_bg.jpeg',
          targetWidth: puzzleWidth, targetHeight: puzzleHeight),
      randomOffset
    ];
  }

  Future _load(String asset, {targetHeight: 100, targetWidth: 100}) async {
    ByteData data = await rootBundle.load(asset);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetHeight: targetHeight, targetWidth: targetWidth);
    ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  double progress = 20;
  bool _result = false;
  var _startDate, _endDate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        child: Container(
          width: widget.width.toDouble(),
          child: FutureBuilder(
              future: _futureBuilder,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError)
                    return Text('Error: ${snapshot.error}');
                  ui.Image mask = snapshot.data[0];
                  ui.Image image = snapshot.data[1];
                  Offset offset = snapshot.data[2];
                  if (_startDate == null) {
                    _startDate = DateTime.now().millisecondsSinceEpoch;
                  }
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(
                        height: 50,
                        child: Stack(
                          children: <Widget>[
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                '请完成验证',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black),
                              ),
                            ),
                            Positioned(
                              right: 14,
                              child: IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () =>
                                    Navigator.pop(context, _result),
                              ),
                            )
                          ],
                        ),
                      ),
                      Stack(
                        children: <Widget>[
                          CustomPaint(
                            painter: PuzzlePainter(mask, image, progress,
                                offsetY: offset.dy, blockOffsetX: offset.dx),
                            size: Size(snapshot.data[1].width.toDouble(),
                                snapshot.data[1].height.toDouble()),
                          ),
                          _endDate != null
                              ? Container(
                                  alignment: AlignmentDirectional.center,
                                  color: Colors.green.withOpacity(0.8),
                                  height: image.height.toDouble(),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Image.asset(
                                        'assets/images/ic_checked.png',
                                        color: Colors.white,
                                        height: 50,
                                        fit: BoxFit.fill,
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        '验证成功，耗时${(_endDate - _startDate) / 1000}秒',
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                )
                              : SizedBox()
                        ],
                      ),
                      Container(
                        color: Colors.white,
                        padding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        child: ConfirmationSlider(
                          onConfirmation: () => print('ss'),
                          height: 50,
                          foregroundColor: Theme.of(context).accentColor,
                          textStyle:
                              TextStyle(fontSize: 12, color: Colors.grey),
                          width: widget.width - 20.0,
                          text: '按住左边滑块，拖动完成上方拼图',
                          onUpdate: (v, r) {
                            v += 20;
                            setState(() {
                              progress = v;
                            });
                            if (r) {
                              if (v <= offset.dx + 5 && v >= offset.dx - 5) {
                                //验证通过
                                setState(() {
                                  _endDate =
                                      DateTime.now().millisecondsSinceEpoch;
                                });
                                _result = true;
                                Future.delayed(Duration(seconds: 1), () {
                                  Navigator.pop(context, _result);
                                });
                                return true;
                              } else {
                                setState(() {
                                  progress = 20;
                                });
                              }
                            }

                            return false;
                          },
                        ),
                      ),
                    ],
                  );
                } else {
                  return CupertinoActivityIndicator();
                }
              }),
        ),
      ),
    );
  }
}

class ConfirmationSlider extends StatefulWidget {
  final double height;

  final double width;

  final Color backgroundColor;

  final Color foregroundColor;

  final Color iconColor;

  final IconData icon;

  final BoxShadow shadow;

  final String text;

  final TextStyle textStyle;

  final VoidCallback onConfirmation;

  final BorderRadius foregroundShape;

  final BorderRadius backgroundShape;
  final Function onUpdate;

  const ConfirmationSlider(
      {Key key,
      this.height = 70,
      this.width = 300,
      this.backgroundColor = Colors.white,
      this.foregroundColor = Colors.blueAccent,
      this.iconColor = Colors.white,
      this.shadow,
      this.onUpdate,
      this.icon = Icons.chevron_right,
      this.text = "Slide to confirm",
      this.textStyle,
      @required this.onConfirmation,
      this.foregroundShape,
      this.backgroundShape});

  @override
  State<StatefulWidget> createState() {
    return ConfirmationSliderState();
  }
}

class ConfirmationSliderState extends State<ConfirmationSlider> {
  double _position = 0;
  int _duration = 0;

  double getPosition() {
    var p = 0.0;
    if (_position < 0) {
      p = 0;
    } else if (_position > widget.width - widget.height) {
      p = widget.width - widget.height;
    } else {
      p = _position;
    }

    return p;
  }

  bool stop = false;

  void updatePosition(details) {
    if (stop) return;
    if (details is DragEndDetails) {
      if (widget.onUpdate != null) {
        stop = widget.onUpdate(getPosition(), true);
      }
      if (!stop) {
        setState(() {
          _duration = 600;
          _position = 0;
        });
      }
    } else if (details is DragUpdateDetails) {
      setState(() {
        _duration = 0;
        _position = details.localPosition.dx - (widget.height / 2);
      });
      if (widget.onUpdate != null) {
        stop = widget.onUpdate(getPosition(), false);
      }
    } else {
      if (widget.onUpdate != null) {
        stop = widget.onUpdate(getPosition(), false);
      }
    }
  }

  void sliderReleased(details) {
    if (_position > widget.width - widget.height) {
      widget.onConfirmation();
    }
    updatePosition(details);
  }

  @override
  Widget build(BuildContext context) {
    BoxShadow shadow;
    if (widget.shadow == null) {
      shadow = BoxShadow(
        color: Colors.black38,
        offset: Offset(0, 2),
        blurRadius: 2,
        spreadRadius: 0,
      );
    } else {
      shadow = widget.shadow;
    }

    TextStyle style;
    if (widget.textStyle == null) {
      style = TextStyle(
        color: Colors.black26,
        fontWeight: FontWeight.bold,
      );
    } else {
      style = widget.textStyle;
    }

    return Container(
      height: widget.height,
      width: widget.width,
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: widget.backgroundShape ??
            BorderRadius.all(Radius.circular(widget.height)),
        color: widget.backgroundColor,
        boxShadow: <BoxShadow>[shadow],
      ),
      child: Stack(
        children: <Widget>[
          Center(
            child: Text(
              widget.text,
              style: style,
            ),
          ),
          Positioned(
            left: widget.height / 2,
            child: AnimatedContainer(
              height: widget.height - 10,
              width: getPosition(),
              duration: Duration(milliseconds: _duration),
              curve: Curves.bounceOut,
              decoration: BoxDecoration(
                borderRadius: widget.backgroundShape ??
                    BorderRadius.all(Radius.circular(widget.height)),
                color: widget.backgroundColor,
              ),
            ),
          ),
          AnimatedPositioned(
            duration: Duration(milliseconds: _duration),
            curve: Curves.bounceOut,
            left: getPosition(),
            top: 0,
            child: GestureDetector(
              onPanUpdate: (details) => updatePosition(details),
              onPanEnd: (details) => sliderReleased(details),
              child: Container(
                height: widget.height - 10,
                width: widget.height - 10,
                decoration: BoxDecoration(
                  borderRadius: widget.foregroundShape ??
                      BorderRadius.all(Radius.circular(widget.height / 2)),
                  color: widget.foregroundColor,
                ),
                child: Icon(
                  widget.icon,
                  color: widget.iconColor,
                  size: widget.height * 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PuzzlePainter extends CustomPainter {
  ui.Image mask, image;
  double progress = 0, offsetY, blockOffsetX;

  PuzzlePainter(this.mask, this.image, this.progress,
      {@required this.offsetY, @required this.blockOffsetX});

  @override
  void paint(Canvas canvas, Size size) {
    if (image != null && mask != null) {
      Paint paint = Paint()
        ..isAntiAlias = true
        ..filterQuality = FilterQuality.high;
      canvas.drawImage(image, Offset(0, 0), paint);
      canvas.drawImage(
          mask, Offset(blockOffsetX, offsetY), paint..color = Colors.black54);
      var rect = Rect.fromLTWH(
          progress, offsetY, mask.width.toDouble(), mask.height.toDouble());

      canvas.saveLayer(rect, paint..color = Colors.white);
      Rect maskRect =
          Rect.fromLTWH(0, 0, mask.width.toDouble(), mask.height.toDouble());
      canvas.drawImageRect(mask, maskRect, rect, paint);

      //Image
      Rect offsetRect = Rect.fromLTWH(progress - blockOffsetX, 0,
          image.width.toDouble(), image.height.toDouble());
      Rect imageRect =
          Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
      canvas.drawImageRect(
          image, imageRect, offsetRect, paint..blendMode = BlendMode.srcIn);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(PuzzlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
