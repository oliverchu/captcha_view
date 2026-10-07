import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Called when the slider position changes or the user releases the slider.
///
/// [progress] is the current position of the slider in logical pixels and
/// [released] is `true` when the user lifted their finger.
///
/// Returns `true` to keep the slider at [progress], or `false` to animate it
/// back to the start.
typedef SliderUpdateCallback = bool Function(double progress, bool released);

/// The loaded puzzle assets and the random target offset of the puzzle piece.
typedef PuzzleAssets = (ui.Image mask, ui.Image image, Offset offset);

/// A slide-to-verify puzzle captcha widget.
///
/// Displays a background image with a missing puzzle piece. The user must
/// drag the slider to move the piece to its correct position to pass the
/// verification.
///
/// Can be pushed as a route, embedded in a layout, or shown using [SlideVerifyView.show]:
///
/// ```dart
/// final verified = await SlideVerifyView.show(context);
/// if (verified == true) {
///   // Verification succeeded!
/// }
/// ```
class SlideVerifyView extends StatefulWidget {
  /// Creates a slide-to-verify widget.
  const SlideVerifyView({
    super.key,
    this.width = 300,
    this.title = 'Please complete the verification',
    this.sliderText = 'Slide to complete the puzzle',
    this.successTextBuilder,
    this.showCloseButton = true,
    this.tolerance = 5.0,
    this.autoDismiss = true,
    this.autoDismissDelay = const Duration(seconds: 1),
    this.maskImageAsset = 'packages/captcha_view/assets/images/3.0x/ic_puzzle.png',
    this.bgImageAsset = 'packages/captcha_view/assets/images/3.0x/ic_verify_bg.jpeg',
    this.onSuccess,
    this.onFail,
    this.onClose,
  });

  /// The width of the widget in logical pixels.
  final int width;

  /// The title displayed at the top of the card.
  final String title;

  /// The hint text displayed on the slider track.
  final String sliderText;

  /// Builder for the success message overlay.
  ///
  /// Receives the elapsed verification time in seconds. If `null`, defaults to
  /// `'Verified in ${elapsedSeconds.toStringAsFixed(1)}s'`.
  final String Function(double elapsedSeconds)? successTextBuilder;

  /// Whether to display a close button in the header.
  final bool showCloseButton;

  /// Allowed tolerance in pixels from the target puzzle position.
  final double tolerance;

  /// Whether to automatically pop the route/dialog when verification succeeds.
  final bool autoDismiss;

  /// Delay before automatically popping the route on success.
  final Duration autoDismissDelay;

  /// Asset path for the puzzle piece mask image.
  final String maskImageAsset;

  /// Asset path for the background puzzle image.
  final String bgImageAsset;

  /// Callback invoked when the user successfully solves the puzzle.
  /// Passes the time taken in seconds.
  final ValueChanged<double>? onSuccess;

  /// Callback invoked when the user releases the slider in the wrong position.
  final VoidCallback? onFail;

  /// Callback invoked when the user taps the close button.
  final VoidCallback? onClose;

  /// Shows the [SlideVerifyView] as a dialog modal.
  ///
  /// Returns `true` if verification passed, `false` or `null` otherwise.
  static Future<bool?> show(
    BuildContext context, {
    int width = 300,
    String title = 'Please complete the verification',
    String sliderText = 'Slide to complete the puzzle',
    String Function(double elapsedSeconds)? successTextBuilder,
    bool showCloseButton = true,
    double tolerance = 5.0,
    bool autoDismiss = true,
    Duration autoDismissDelay = const Duration(seconds: 1),
    String maskImageAsset = 'packages/captcha_view/assets/images/3.0x/ic_puzzle.png',
    String bgImageAsset = 'packages/captcha_view/assets/images/3.0x/ic_verify_bg.jpeg',
    ValueChanged<double>? onSuccess,
    VoidCallback? onFail,
    VoidCallback? onClose,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: SlideVerifyView(
          width: width,
          title: title,
          sliderText: sliderText,
          successTextBuilder: successTextBuilder,
          showCloseButton: showCloseButton,
          tolerance: tolerance,
          autoDismiss: autoDismiss,
          autoDismissDelay: autoDismissDelay,
          maskImageAsset: maskImageAsset,
          bgImageAsset: bgImageAsset,
          onSuccess: onSuccess,
          onFail: onFail,
          onClose: onClose,
        ),
      ),
    );
  }

  @override
  State<SlideVerifyView> createState() => _SlideVerifyViewState();
}

class _SlideVerifyViewState extends State<SlideVerifyView> {
  late Future<PuzzleAssets> _futureBuilder;

  double _progress = 20;
  bool _result = false;
  int? _startDate;
  int? _endDate;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _futureBuilder = _init(widget.width);
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  Future<PuzzleAssets> _init(int puzzleWidth) async {
    final random = Random();

    final puzzleHeight = (puzzleWidth * 0.7).toInt();
    final blockSize = puzzleWidth ~/ 6;
    final randomOffset = Offset(
      (random.nextInt(puzzleWidth ~/ 2) + blockSize).toDouble(),
      (random.nextInt(puzzleHeight ~/ 2) + 10).toDouble(),
    );
    final mask = await _load(
      widget.maskImageAsset,
      targetWidth: blockSize,
      targetHeight: blockSize,
    );
    final image = await _load(
      widget.bgImageAsset,
      targetWidth: puzzleWidth,
      targetHeight: puzzleHeight,
    );
    return (mask, image, randomOffset);
  }

  Future<ui.Image> _load(
    String asset, {
    required int targetHeight,
    required int targetWidth,
  }) async {
    final data = await rootBundle.load(asset);
    final codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetHeight: targetHeight,
      targetWidth: targetWidth,
    );
    final frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }

  void _handleClose() {
    widget.onClose?.call();
    if (Navigator.canPop(context)) {
      Navigator.pop(context, _result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SizedBox(
        width: widget.width.toDouble(),
        child: FutureBuilder<PuzzleAssets>(
          future: _futureBuilder,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return SizedBox(
                height: (widget.width * 0.7) + 100,
                child: const Center(child: CupertinoActivityIndicator()),
              );
            }
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error loading captcha: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
            final (mask, image, offset) = snapshot.data!;
            _startDate ??= DateTime.now().millisecondsSinceEpoch;
            final elapsedSeconds = _endDate != null
                ? (_endDate! - _startDate!) / 1000.0
                : 0.0;

            final successMessage = widget.successTextBuilder?.call(elapsedSeconds) ??
                'Verified in ${elapsedSeconds.toStringAsFixed(1)}s';

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 50,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      if (widget.showCloseButton)
                        Positioned(
                          right: 6,
                          top: 2,
                          child: IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: _handleClose,
                          ),
                        ),
                    ],
                  ),
                ),
                Stack(
                  children: [
                    CustomPaint(
                      painter: PuzzlePainter(
                        mask,
                        image,
                        _progress,
                        offsetY: offset.dy,
                        blockOffsetX: offset.dx,
                      ),
                      size: Size(
                        image.width.toDouble(),
                        image.height.toDouble(),
                      ),
                    ),
                    if (_endDate != null)
                      Container(
                        alignment: AlignmentDirectional.center,
                        color: Colors.green.withValues(alpha: 0.85),
                        height: image.height.toDouble(),
                        width: image.width.toDouble(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 48,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              successMessage,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 10,
                  ),
                  child: ConfirmationSlider(
                    onConfirmation: () {},
                    height: 48,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    textStyle: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    width: widget.width - 20.0,
                    text: widget.sliderText,
                    onUpdate: (value, released) {
                      final progress = value + 20;
                      setState(() => _progress = progress);
                      if (released) {
                        final diff = (progress - offset.dx).abs();
                        if (diff <= widget.tolerance) {
                          // Verification succeeded
                          final now = DateTime.now().millisecondsSinceEpoch;
                          setState(() {
                            _endDate = now;
                            _result = true;
                          });
                          final elapsed = (now - _startDate!) / 1000.0;
                          widget.onSuccess?.call(elapsed);

                          if (widget.autoDismiss) {
                            _dismissTimer = Timer(widget.autoDismissDelay, () {
                              if (mounted && Navigator.canPop(context)) {
                                Navigator.pop(context, true);
                              }
                            });
                          }
                          return true;
                        } else {
                          // Verification failed
                          widget.onFail?.call();
                          setState(() => _progress = 20);
                        }
                      }
                      return false;
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// A slider that the user must drag to confirm an action.
///
/// The thumb follows the user's finger while dragging and animates back to
/// the start when the drag ends, unless [onUpdate] returns `true`.
class ConfirmationSlider extends StatefulWidget {
  /// Creates a confirmation slider.
  const ConfirmationSlider({
    super.key,
    this.height = 70,
    this.width = 300,
    this.backgroundColor = Colors.white,
    this.foregroundColor = Colors.blueAccent,
    this.iconColor = Colors.white,
    this.shadow,
    this.onUpdate,
    this.icon = Icons.chevron_right,
    this.text = 'Slide to confirm',
    this.textStyle,
    required this.onConfirmation,
    this.foregroundShape,
    this.backgroundShape,
  });

  /// The height of the slider.
  final double height;

  /// The width of the slider.
  final double width;

  /// The color of the slider track.
  final Color backgroundColor;

  /// The color of the slider thumb.
  final Color foregroundColor;

  /// The color of the icon on the slider thumb.
  final Color iconColor;

  /// The shadow of the slider track.
  final BoxShadow? shadow;

  /// Called when the position changes or the user releases the slider.
  final SliderUpdateCallback? onUpdate;

  /// The icon shown on the slider thumb.
  final IconData icon;

  /// The hint text shown in the middle of the slider.
  final String text;

  /// The style of the hint text.
  final TextStyle? textStyle;

  /// Called when the slider is dragged to the end.
  final VoidCallback onConfirmation;

  /// The shape of the slider thumb.
  final BorderRadius? foregroundShape;

  /// The shape of the slider track.
  final BorderRadius? backgroundShape;

  @override
  State<ConfirmationSlider> createState() => _ConfirmationSliderState();
}

class _ConfirmationSliderState extends State<ConfirmationSlider> {
  double _position = 0;
  int _duration = 0;
  bool _stop = false;

  double _getPosition() {
    final maxPos = widget.width - widget.height;
    if (_position < 0) {
      return 0;
    } else if (_position > maxPos) {
      return maxPos > 0 ? maxPos : 0;
    } else {
      return _position;
    }
  }

  void _updatePositionOnDrag(DragUpdateDetails details) {
    setState(() {
      _duration = 0;
      _position = details.localPosition.dx - (widget.height / 2);
    });
    _stop = widget.onUpdate?.call(_getPosition(), false) ?? false;
  }

  void _updatePositionOnRelease(DragEndDetails details) {
    if (_stop) {
      return;
    }
    _stop = widget.onUpdate?.call(_getPosition(), true) ?? false;
    if (!_stop) {
      setState(() {
        _duration = 600;
        _position = 0;
      });
    }
  }

  void _sliderReleased(DragEndDetails details) {
    if (_position > widget.width - widget.height) {
      widget.onConfirmation();
    }
    _updatePositionOnRelease(details);
  }

  @override
  Widget build(BuildContext context) {
    final shadow = widget.shadow ??
        const BoxShadow(
          color: Colors.black12,
          offset: Offset(0, 2),
          blurRadius: 4,
          spreadRadius: 0,
        );

    final style = widget.textStyle ??
        const TextStyle(
          color: Colors.black38,
          fontWeight: FontWeight.bold,
        );

    final trackRadius = widget.backgroundShape ?? BorderRadius.circular(widget.height);
    final thumbRadius = widget.foregroundShape ?? BorderRadius.circular(widget.height / 2);

    return Container(
      height: widget.height,
      width: widget.width,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: trackRadius,
        color: widget.backgroundColor,
        boxShadow: <BoxShadow>[shadow],
      ),
      child: Stack(
        children: [
          Center(
            child: Text(widget.text, style: style),
          ),
          Positioned(
            left: widget.height / 2,
            child: AnimatedContainer(
              height: widget.height - 8,
              width: _getPosition(),
              duration: Duration(milliseconds: _duration),
              curve: Curves.bounceOut,
              decoration: BoxDecoration(
                borderRadius: trackRadius,
                color: widget.backgroundColor,
              ),
            ),
          ),
          AnimatedPositioned(
            duration: Duration(milliseconds: _duration),
            curve: Curves.bounceOut,
            left: _getPosition(),
            top: 0,
            child: GestureDetector(
              onPanUpdate: _updatePositionOnDrag,
              onPanEnd: _sliderReleased,
              child: Container(
                height: widget.height - 8,
                width: widget.height - 8,
                decoration: BoxDecoration(
                  borderRadius: thumbRadius,
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

/// A painter that draws the puzzle captcha.
///
/// Draws the background image, marks the target position of the puzzle
/// piece, and draws the piece itself at the current [progress].
class PuzzlePainter extends CustomPainter {
  /// Creates a puzzle painter.
  PuzzlePainter(
    this.mask,
    this.image,
    this.progress, {
    required this.offsetY,
    required this.blockOffsetX,
  });

  /// The image of the puzzle piece.
  final ui.Image mask;

  /// The background image.
  final ui.Image image;

  /// The current horizontal position of the puzzle piece.
  final double progress;

  /// The vertical offset of the puzzle piece on the background.
  final double offsetY;

  /// The horizontal offset of the puzzle piece on the background.
  final double blockOffsetX;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.high;
    canvas.drawImage(image, Offset.zero, paint);
    canvas.drawImage(
      mask,
      Offset(blockOffsetX, offsetY),
      paint..color = Colors.black54,
    );
    final rect = Rect.fromLTWH(
      progress,
      offsetY,
      mask.width.toDouble(),
      mask.height.toDouble(),
    );

    canvas.saveLayer(rect, paint..color = Colors.white);
    final maskRect = Rect.fromLTWH(
      0,
      0,
      mask.width.toDouble(),
      mask.height.toDouble(),
    );
    canvas.drawImageRect(mask, maskRect, rect, paint);

    // Image
    final offsetRect = Rect.fromLTWH(
      progress - blockOffsetX,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );
    final imageRect = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );
    canvas.drawImageRect(
      image,
      imageRect,
      offsetRect,
      paint..blendMode = BlendMode.srcIn,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant PuzzlePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.offsetY != offsetY ||
        oldDelegate.blockOffsetX != blockOffsetX ||
        oldDelegate.mask != mask ||
        oldDelegate.image != image;
  }
}
