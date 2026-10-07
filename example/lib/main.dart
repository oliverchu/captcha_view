import 'package:captcha_view/captcha_view.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const CaptchaViewExampleApp());
}

class CaptchaViewExampleApp extends StatelessWidget {
  const CaptchaViewExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Captcha View Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Text Captcha 1
  String _text1 = CaptchaView.generateText(length: 4, excludeSimilar: true);
  // Text Captcha 2
  String _text2 = CaptchaView.generateText(length: 6, withNumber: true, withLetter: true);

  void _refreshAll() {
    setState(() {
      _text1 = CaptchaView.generateText(length: 4, excludeSimilar: true);
      _text2 = CaptchaView.generateText(length: 6, withNumber: true, withLetter: true);
    });
  }

  Future<void> _showSlideVerifyDialog({
    required PuzzleStyle style,
    Color strokeColor = Colors.black54,
    double strokeWidth = 1.5,
    int? puzzleSize,
  }) async {
    final verified = await SlideVerifyView.show(
      context,
      title: 'Security Verification (${style.name.toUpperCase()})',
      sliderText: 'Slide to match the puzzle piece',
      imageProvider: const NetworkImage('https://picsum.photos/300/210'),
      puzzleStyle: style,
      puzzleStrokeColor: strokeColor,
      puzzleStrokeWidth: strokeWidth,
      puzzleSize: puzzleSize,
      successTextBuilder: (seconds) => 'Passed in ${seconds.toStringAsFixed(2)}s! 🎉',
      onSuccess: (seconds) {
        debugPrint('Verification succeeded in $seconds seconds');
      },
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          verified == true ? 'Verification Passed! ✅' : 'Verification Cancelled ❌',
        ),
      ),
    );
  }

  Future<void> _openInlineVerifyPage() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Inline Slide Verification Page')),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SlideVerifyView(
                    width: 300,
                    title: 'Complete Puzzle',
                    sliderText: 'Drag right to verify',
                    imageProvider: const NetworkImage('https://picsum.photos/300/210'),
                    puzzleStyle: PuzzleStyle.square,
                    puzzleStrokeColor: Colors.blueAccent,
                    puzzleStrokeWidth: 2.0,
                    onSuccess: (seconds) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Verified successfully in ${seconds}s!')),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('captcha_view Comprehensive Examples'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '1. Text Captchas (CaptchaView)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                
                // Example 1: 4-digit clean text captcha
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text('Style A: 4-Digit with Rainbow Lines', style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 8),
                        CaptchaView(
                          text: _text1,
                          lineColors: CaptchaView.rainbowColors,
                          lineCount: 5,
                          width: 240,
                          height: 45,
                          onTap: _refreshAll,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Example 2: 6-digit customized container decoration
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text('Style B: 6-Digit Custom Decorated', style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 8),
                        CaptchaView(
                          text: _text2,
                          lineColors: [Colors.blue, Colors.red, Colors.green],
                          lineCount: 8,
                          width: 240,
                          height: 45,
                          onTap: _refreshAll,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.deepPurple.shade200, width: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _refreshAll,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh All Text Captchas'),
                ),

                const Divider(height: 48),

                const Text(
                  '2. Slide Puzzle Captchas (SlideVerifyView)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Style 1: Jigsaw Puzzle
                ElevatedButton.icon(
                  onPressed: () => _showSlideVerifyDialog(
                    style: PuzzleStyle.puzzle,
                    strokeColor: Colors.black54,
                    strokeWidth: 1.5,
                  ),
                  icon: const Icon(Icons.extension),
                  label: const Text('Jigsaw Puzzle Style (Classic)'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                const SizedBox(height: 12),

                // Style 2: Square Rounded Style with custom stroke & size
                ElevatedButton.icon(
                  onPressed: () => _showSlideVerifyDialog(
                    style: PuzzleStyle.square,
                    strokeColor: Colors.blueAccent,
                    strokeWidth: 2.0,
                    puzzleSize: 38,
                  ),
                  icon: const Icon(Icons.square_outlined),
                  label: const Text('Square Rounded Style (Blue Stroke)'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                const SizedBox(height: 12),

                // Style 3: Circle Style with deep purple stroke
                ElevatedButton.icon(
                  onPressed: () => _showSlideVerifyDialog(
                    style: PuzzleStyle.circle,
                    strokeColor: Colors.deepPurple,
                    strokeWidth: 2.0,
                  ),
                  icon: const Icon(Icons.circle_outlined),
                  label: const Text('Circle Style (Deep Purple Stroke)'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                const SizedBox(height: 12),

                // Style 4: Inline Embedded Page Route
                FilledButton.tonalIcon(
                  onPressed: _openInlineVerifyPage,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open Inline Embedded Verify Page'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
