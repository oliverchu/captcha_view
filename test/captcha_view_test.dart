import 'package:captcha_view/captcha_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CaptchaView.generateText', () {
    test('generates text with the requested length', () {
      expect(CaptchaView.generateText(length: 1).length, 1);
      expect(CaptchaView.generateText(length: 10).length, 10);
      expect(CaptchaView.generateText().length, 4);
    });

    test('generates only letters when withNumber is false', () {
      final text = CaptchaView.generateText(length: 50, withNumber: false);
      expect(text, matches(RegExp(r'^[a-zA-Z]+$')));
    });

    test('generates only digits when withLetter is false', () {
      final text = CaptchaView.generateText(length: 50, withLetter: false);
      expect(text, matches(RegExp(r'^[0-9]+$')));
    });

    test('excludes similar characters when excludeSimilar is true', () {
      final text = CaptchaView.generateText(
        length: 200,
        excludeSimilar: true,
      );
      for (final char in ['0', 'O', 'o', '1', 'I', 'l']) {
        expect(text.contains(char), isFalse);
      }
    });

    test('uses customAllowedCharacters when provided', () {
      final text = CaptchaView.generateText(
        length: 20,
        customAllowedCharacters: 'ABC',
      );
      expect(text, matches(RegExp(r'^[ABC]+$')));
    });

    test('generates different texts on subsequent calls', () {
      final texts = {
        for (var i = 0; i < 10; i++) CaptchaView.generateText(length: 8),
      };
      expect(texts.length, greaterThan(1));
    });
  });

  group('CaptchaView', () {
    testWidgets('renders every character of the text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CaptchaView(text: 'Ab12'),
          ),
        ),
      );

      for (final char in ['A', 'b', '1', '2']) {
        expect(find.text(char), findsOneWidget);
      }
    });

    testWidgets('renders a CustomPaint for the mask lines', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CaptchaView(
              text: 'Ab12',
              lineColors: CaptchaView.rainbowColors,
            ),
          ),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(CaptchaView),
          matching: find.byType(CustomPaint),
        ),
        findsOneWidget,
      );
    });

    testWidgets('triggers onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CaptchaView(
              text: 'Ab12',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CaptchaView));
      expect(tapped, isTrue);
    });
  });
}
