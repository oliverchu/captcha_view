import 'dart:typed_data';
import 'package:captcha_view/captcha_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final Uint8List kTransparentImage = Uint8List.fromList(<int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xc4, 0x89, 0x00, 0x00, 0x00,
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

void main() {
  group('ConfirmationSlider', () {
    testWidgets('renders the hint text and the thumb icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConfirmationSlider(
              width: 300,
              height: 50,
              text: 'Slide to confirm',
              onConfirmation: () {},
            ),
          ),
        ),
      );

      expect(find.text('Slide to confirm'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('calls onUpdate while dragging and on release', (tester) async {
      final updates = <double>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConfirmationSlider(
              width: 300,
              height: 50,
              onConfirmation: () {},
              onUpdate: (progress, released) {
                updates.add(progress);
                return false;
              },
            ),
          ),
        ),
      );

      await tester.drag(find.byIcon(Icons.chevron_right), const Offset(100, 0));
      await tester.pump();

      expect(updates, isNotEmpty);
      expect(updates.last, greaterThan(50));
    });

    testWidgets('calls onConfirmation when dragged to the end', (tester) async {
      var confirmed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConfirmationSlider(
              width: 300,
              height: 50,
              onConfirmation: () => confirmed = true,
              onUpdate: (progress, released) => false,
            ),
          ),
        ),
      );

      await tester.drag(find.byIcon(Icons.chevron_right), const Offset(500, 0));
      await tester.pump();

      expect(confirmed, isTrue);
    });
  });

  group('SlideVerifyView', () {
    testWidgets('loads the puzzle assets and renders custom strings', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SlideVerifyView(
              title: 'Custom Title',
              sliderText: 'Custom Slider Hint',
              imageProvider: MemoryImage(kTransparentImage),
              puzzleStrokeColor: Colors.red,
              puzzleStrokeWidth: 2.0,
            ),
          ),
        ),
      );

      var loaded = false;
      for (var i = 0; i < 10 && !loaded; i++) {
        await tester.runAsync(() => Future<void>.delayed(
              const Duration(milliseconds: 50),
            ));
        await tester.pump();
        loaded = find.text('Custom Title').evaluate().isNotEmpty;
      }

      expect(loaded, isTrue);
      expect(find.text('Custom Title'), findsOneWidget);
      expect(find.text('Custom Slider Hint'), findsOneWidget);
    });
  });
}
