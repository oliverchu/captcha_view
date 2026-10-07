# captcha_view

[![pub package](https://img.shields.io/pub/v/captcha_view.svg)](https://pub.dev/packages/captcha_view)
[![likes](https://img.shields.io/pub/likes/captcha_view)](https://pub.dev/packages/captcha_view/score)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

**English** | [简体中文](README_ZH.md)

A lightweight and highly customizable Flutter package providing secure human verification widgets, including distorted text captchas and interactive slide-to-verify puzzle captchas.

## Features

- **Text Captcha (`CaptchaView`)**: Generates random letters and digits with character skew/distortion and colorful smooth watermark curves to prevent OCR scraping.
- **Slide-to-Verify Puzzle Captcha (`SlideVerifyView`)**: An interactive drag-and-drop puzzle captcha widget supporting dialog modals, routes, and custom callbacks.
- **Pure Vector & Programmatic Puzzle Styles (`PuzzleStyle`)**: Generates puzzle shapes dynamically (`puzzle`, `square`, `circle`) without external asset files.
- **Custom Image Support**: Accepts any `ImageProvider` (NetworkImage, AssetImage, etc.) as the puzzle background.
- **Customizable Stroke & Shadow**: Adjustable puzzle piece stroke color, width, and realistic drop shadow.
- **Easy One-Line Dialogs**: Convenient `SlideVerifyView.show(context)` helper method.

---

## Preview & Effect Showcase

| Overview | Jigsaw Puzzle Style | Square Rounded Style |
| :---: | :---: | :---: |
| ![All](screenshot/all.png) | ![Puzzle](screenshot/img_1.png) | ![Square](screenshot/img_2.png) |

| Circle Style | Custom Variation 1 | Custom Variation 2 |
| :---: | :---: | :---: |
| ![Circle](screenshot/img_3.png) | ![Style 1](screenshot/img_4.png) | ![Style 2](screenshot/img_5.png) |

---

## Installation

Add `captcha_view` to your `pubspec.yaml`:

```yaml
dependencies:
  captcha_view: ^1.0.0
```

Or run:

```bash
flutter pub add captcha_view
```

Then import it in your Dart code:

```dart
import 'package:captcha_view/captcha_view.dart';
```

---

## Usage

### 1. Text Captcha (`CaptchaView`)

#### Basic Usage

Generate random characters using `CaptchaView.generateText` and display them:

```dart
CaptchaView(
  text: CaptchaView.generateText(length: 6),
)
```

#### Tap to Refresh & Exclude Confusing Characters

Allow users to tap the captcha to refresh the text, while omitting ambiguous characters (`0`, `O`, `1`, `I`, `l`):

```dart
String captchaText = CaptchaView.generateText(
  length: 6,
  excludeSimilar: true,
);

CaptchaView(
  text: captchaText,
  lineColors: CaptchaView.rainbowColors,
  onTap: () {
    setState(() {
      captchaText = CaptchaView.generateText(
        length: 6,
        excludeSimilar: true,
      );
    });
  },
)
```

#### Custom Decoration & Styling

Custom background, rounded corners, border, and line counts:

```dart
CaptchaView(
  text: CaptchaView.generateText(length: 4),
  lineColors: [Colors.blue, Colors.purple, Colors.red],
  lineCount: 4,
  width: 200,
  height: 50,
  style: const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    letterSpacing: 2,
  ),
  decoration: BoxDecoration(
    color: Colors.grey.shade100,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.deepPurple.shade200),
  ),
)
```

---

### 2. Slide Puzzle Captcha (`SlideVerifyView`)

#### Show as Modal Dialog with Custom Image & Style

Show the verification puzzle inside a pop-up dialog with custom network images and puzzle styles (`PuzzleStyle.puzzle`, `PuzzleStyle.square`, `PuzzleStyle.circle`):

```dart
final verified = await SlideVerifyView.show(
  context,
  title: 'Security Check',
  sliderText: 'Slide to complete the puzzle',
  imageProvider: const NetworkImage('https://picsum.photos/300/210'),
  puzzleStyle: PuzzleStyle.puzzle,
  puzzleStrokeColor: Colors.black54,
  puzzleStrokeWidth: 1.5,
  onSuccess: (elapsedSeconds) {
    print('Verified in $elapsedSeconds seconds');
  },
);

if (verified == true) {
  // User passed verification
}
```

#### Embed as Route or Widget

Push `SlideVerifyView` directly to the navigator stack or embed it inside your own widget tree:

```dart
final verified = await Navigator.of(context).push<bool>(
  MaterialPageRoute(
    builder: (_) => Scaffold(
      appBar: AppBar(title: const Text('Verify Identity')),
      body: Center(
        child: SlideVerifyView(
          title: 'Please complete verification',
          sliderText: 'Drag slider to match the piece',
          imageProvider: const NetworkImage('https://picsum.photos/300/210'),
          puzzleStyle: PuzzleStyle.square,
        ),
      ),
    ),
  ),
);
```

---

## Puzzle Styles & Parameter Configurations

`SlideVerifyView` provides 3 flexible geometric shape styles via `PuzzleStyle`:

### 1. Jigsaw Puzzle Style (`PuzzleStyle.puzzle`)
The classic jigsaw puzzle piece shape with convex tabs and concave indentations on its edges.

```dart
SlideVerifyView(
  imageProvider: NetworkImage('https://picsum.photos/300/210'),
  puzzleStyle: PuzzleStyle.puzzle,
  puzzleStrokeColor: Colors.black87,
  puzzleStrokeWidth: 1.5,
  puzzleSize: 40, // Optional custom piece size
)
```

### 2. Square Rounded Style (`PuzzleStyle.square`)
A modern rounded rectangle puzzle piece shape.

```dart
SlideVerifyView(
  imageProvider: NetworkImage('https://picsum.photos/300/210'),
  puzzleStyle: PuzzleStyle.square,
  puzzleStrokeColor: Colors.blueAccent,
  puzzleStrokeWidth: 2.0,
)
```

### 3. Circle Style (`PuzzleStyle.circle`)
A clean circular puzzle piece shape.

```dart
SlideVerifyView(
  imageProvider: NetworkImage('https://picsum.photos/300/210'),
  puzzleStyle: PuzzleStyle.circle,
  puzzleStrokeColor: Colors.deepPurple,
  puzzleStrokeWidth: 2.0,
)
```

---

## API Reference

### `CaptchaView`

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `String` | `''` | The text to display in the captcha. |
| `width` | `double` | `double.infinity` | Width of the captcha container. |
| `height` | `double` | `40` | Height of the captcha container. |
| `backgroundColor` | `Color` | `Colors.white` | Background color (overridden by `decoration`). |
| `style` | `TextStyle` | `TextStyle(fontSize: 18)` | Text style used for the captcha characters. |
| `lineColors` | `List<Color>?` | `null` | Colors for the disturbance lines. Draws no lines if `null`. |
| `lineCount` | `int` | `4` | Number of mask curves to draw over the text. |
| `decoration` | `BoxDecoration?` | `null` | Custom container decoration. |
| `onTap` | `VoidCallback?` | `null` | Callback triggered when the captcha is tapped. |

#### `CaptchaView.generateText()`

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `length` | `int` | `4` | Number of characters to generate. |
| `withNumber` | `bool` | `true` | Include digits (`0-9`). |
| `withLetter` | `bool` | `true` | Include letters (`A-Z`, `a-z`). |
| `excludeSimilar` | `bool` | `false` | Exclude confusing characters (`0`, `O`, `o`, `1`, `I`, `l`). |
| `customAllowedCharacters` | `String?` | `null` | Optional custom character pool string. |

---

### `SlideVerifyView`

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `imageProvider` | `ImageProvider` | *(required)* | Background image provider (e.g. `NetworkImage`). |
| `width` | `int` | `300` | Width of the puzzle widget in pixels. |
| `title` | `String` | `'Please complete the verification'` | Title text at the top header. |
| `sliderText` | `String` | `'Slide to complete the puzzle'` | Hint text shown on the slider track. |
| `puzzleStyle` | `PuzzleStyle` | `PuzzleStyle.puzzle` | Shape style (`puzzle`, `square`, `circle`). |
| `puzzleSize` | `int?` | `null` | Size of the puzzle piece in logical pixels. |
| `puzzleStrokeColor` | `Color` | `Colors.black` | Stroke color around the puzzle piece. |
| `puzzleStrokeWidth` | `double` | `1.5` | Stroke width around the puzzle piece. |
| `successTextBuilder` | `String Function(double)?` | `null` | Custom builder for the success overlay message. |
| `showCloseButton` | `bool` | `true` | Whether to display the close button. |
| `tolerance` | `double` | `5.0` | Target position accuracy tolerance in logical pixels. |
| `autoDismiss` | `bool` | `true` | Automatically pop route/dialog on success. |
| `autoDismissDelay` | `Duration` | `1 second` | Duration before auto-dismissing on success. |
| `onSuccess` | `ValueChanged<double>?` | `null` | Callback invoked when verification passes (passes elapsed seconds). |
| `onFail` | `VoidCallback?` | `null` | Callback invoked when slider is released in wrong position. |
| `onClose` | `VoidCallback?` | `null` | Callback invoked when close button is tapped. |

---

## License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.
