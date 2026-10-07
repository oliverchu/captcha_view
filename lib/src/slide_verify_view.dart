import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// The style/shape of the slide puzzle piece.
enum PuzzleStyle {
  /// Standard jigsaw puzzle piece with tabs (bumps and indentations).
  puzzle,

  /// Square/rectangle shape with rounded corners.
  square,

  /// Circular shape.
  circle,
}

/// Called when the slider position changes or the user releases the slider.
///
/// [progress] is the current position of the slider in logical pixels and
/// [released] is `true` when the user lifted their finger.
///
/// Returns `true` to keep the slider at [progress], or `false` to animate it
/// back to the start.
typedef SliderUpdateCallback = bool Function(double progress, bool released);

/// A slide-to-verify puzzle captcha widget.
///
/// Displays a background image with a missing puzzle piece. The user must
/// drag the slider to move the piece to its correct position to pass the
/// verification.
///
/// Can be pushed as a route, embedded in a layout, or shown using [SlideVerifyView.show]:
///
/// ```dart
/// final verified = await SlideVerifyView.show(
///   context,
///   imageProvider: NetworkImage('https://picsum.photos/300/210'),
///   puzzleStyle: PuzzleStyle.puzzle,
/// );
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
    required this.imageProvider,
    this.puzzleStyle = PuzzleStyle.puzzle,
    this.puzzleSize,
    this.puzzleStrokeColor = Colors.black,
    this.puzzleStrokeWidth = 1.5,
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

  /// The background image provider to be verified.
  final ImageProvider imageProvider;

  /// The style/shape of the puzzle piece ([PuzzleStyle.puzzle], [PuzzleStyle.square], [PuzzleStyle.circle]).
  final PuzzleStyle puzzleStyle;

  /// The size (width/height) of the puzzle piece in logical pixels.
  final int? puzzleSize;

  /// The color of the stroke around the puzzle piece.
  final Color puzzleStrokeColor;

  /// The width of the stroke around the puzzle piece.
  final double puzzleStrokeWidth;

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
    required ImageProvider imageProvider,
    PuzzleStyle puzzleStyle = PuzzleStyle.puzzle,
    int? puzzleSize,
    Color puzzleStrokeColor = Colors.black,
    double puzzleStrokeWidth = 1.5,
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
          imageProvider: imageProvider,
          puzzleStyle: puzzleStyle,
          puzzleSize: puzzleSize,
          puzzleStrokeColor: puzzleStrokeColor,
          puzzleStrokeWidth: puzzleStrokeWidth,
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
  late Future<ui.Image> _imageFuture;
  late int _blockSize;
  late Offset _randomOffset;

  double _progress = 20;
  bool _result = false;
  int? _startDate;
  int? _endDate;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _imageFuture = _initImage(widget.width);
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  Future<ui.Image> _initImage(int puzzleWidth) async {
    final random = Random();
    final puzzleHeight = (puzzleWidth * 0.7).toInt();
    _blockSize = widget.puzzleSize ?? (puzzleWidth ~/ 8);
    _randomOffset = Offset(
      (random.nextInt(puzzleWidth ~/ 2) + _blockSize).toDouble(),
      (random.nextInt(puzzleHeight ~/ 2) + 10).toDouble(),
    );

    return _loadImageFromProvider(
      widget.imageProvider,
      targetWidth: puzzleWidth,
      targetHeight: puzzleHeight,
    );
  }

  Future<ui.Image> _loadImageFromProvider(
    ImageProvider provider, {
    required int targetHeight,
    required int targetWidth,
  }) async {
    final config = ImageConfiguration(
      size: Size(targetWidth.toDouble(), targetHeight.toDouble()),
    );
    final completer = Completer<ui.Image>();
    final stream = provider.resolve(config);
    late final ImageStreamListener listener;
    listener = ImageStreamListener((imageInfo, synchronousCall) {
      stream.removeListener(listener);
      completer.complete(imageInfo.image);
    }, onError: (exception, stackTrace) {
      stream.removeListener(listener);
      completer.completeError(exception, stackTrace);
    });
    stream.addListener(listener);
    return completer.future;
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
        child: FutureBuilder<ui.Image>(
          future: _imageFuture,
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
            final image = snapshot.data!;
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
                        image,
                        _progress,
                        offsetY: _randomOffset.dy,
                        blockOffsetX: _randomOffset.dx,
                        blockSize: _blockSize.toDouble(),
                        puzzleStyle: widget.puzzleStyle,
                        strokeColor: widget.puzzleStrokeColor,
                        strokeWidth: widget.puzzleStrokeWidth,
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
                        final diff = (progress - _randomOffset.dx).abs();
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
class ConfirmationSlider extends StatefulWidget {
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

  final double height;
  final double width;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color iconColor;
  final BoxShadow? shadow;
  final SliderUpdateCallback? onUpdate;
  final IconData icon;
  final String text;
  final TextStyle? textStyle;
  final VoidCallback onConfirmation;
  final BorderRadius? foregroundShape;
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

/// Helper function to generate puzzle paths for different styles.
Path getPuzzlePath(Rect rect, PuzzleStyle style) {
  switch (style) {
    case PuzzleStyle.square:
      return Path()
        ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6.0)));
    case PuzzleStyle.circle:
      return Path()..addOval(rect);
    case PuzzleStyle.puzzle:
      final l = rect.left;
      final t = rect.top;
      final w = rect.width;
      final h = rect.height;

      final path = Path();
      // Top edge
      path.moveTo(l, t);
      path.lineTo(l + w * 0.35, t);
      path.lineTo(l + w * 0.65, t);
      path.lineTo(l + w, t);

      // Right edge with semicircular tab pointing outwards
      path.lineTo(l + w, t + h * 0.35);
      path.arcToPoint(
        Offset(l + w, t + h * 0.65),
        radius: Radius.circular(h * 0.2),
        clockwise: false,
      );
      path.lineTo(l + w, t + h);

      // Bottom edge with semicircular tab pointing downwards
      path.lineTo(l + w * 0.65, t + h);
      path.arcToPoint(
        Offset(l + w * 0.35, t + h),
        radius: Radius.circular(w * 0.2),
        clockwise: false,
      );
      path.lineTo(l, t + h);

      // Left edge
      path.lineTo(l, t);
      path.close();
      return path;
  }
}

/// A painter that draws the puzzle captcha programmatically using [Path].
class PuzzlePainter extends CustomPainter {
  PuzzlePainter(
    this.image,
    this.progress, {
    required this.offsetY,
    required this.blockOffsetX,
    required this.blockSize,
    required this.puzzleStyle,
    required this.strokeColor,
    required this.strokeWidth,
  });

  final ui.Image image;
  final double progress;
  final double offsetY;
  final double blockOffsetX;
  final double blockSize;
  final PuzzleStyle puzzleStyle;
  final Color strokeColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.high;

    // 1. Draw background image
    canvas.drawImage(image, Offset.zero, paint);

    // Target hole rect & path
    final targetRect = Rect.fromLTWH(blockOffsetX, offsetY, blockSize, blockSize);
    final targetPath = getPuzzlePath(targetRect, puzzleStyle);

    // 2. Draw background missing hole (dark overlay)
    final holePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.55)
      ..isAntiAlias = true;
    canvas.drawPath(targetPath, holePaint);

    if (strokeWidth > 0 && strokeColor != Colors.transparent) {
      final holeStrokePaint = Paint()
        ..color = strokeColor.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..isAntiAlias = true;
      canvas.drawPath(targetPath, holeStrokePaint);
    }

    // Draggable piece local path (at 0,0)
    final localPieceRect = Rect.fromLTWH(0, 0, blockSize, blockSize);
    final localPiecePath = getPuzzlePath(localPieceRect, puzzleStyle);

    // 3. Draw drop shadow for the draggable puzzle piece
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);

    canvas.save();
    canvas.translate(progress + 2, offsetY + 3);
    canvas.drawPath(localPiecePath, shadowPaint);
    canvas.restore();

    // 4. Draw the puzzle piece with fixed target texture content
    canvas.save();
    canvas.translate(progress, offsetY);
    canvas.clipPath(localPiecePath);
    canvas.drawImage(
      image,
      Offset(-blockOffsetX, -offsetY),
      paint,
    );
    canvas.restore();

    // 5. Draw stroke/border around the draggable puzzle piece
    if (strokeWidth > 0 && strokeColor != Colors.transparent) {
      final strokePaint = Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..isAntiAlias = true;
      canvas.save();
      canvas.translate(progress, offsetY);
      canvas.drawPath(localPiecePath, strokePaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant PuzzlePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.offsetY != offsetY ||
        oldDelegate.blockOffsetX != blockOffsetX ||
        oldDelegate.blockSize != blockSize ||
        oldDelegate.puzzleStyle != puzzleStyle ||
        oldDelegate.image != image ||
        oldDelegate.strokeColor != strokeColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
