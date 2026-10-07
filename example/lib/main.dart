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
  String _captchaText = CaptchaView.generateText(
    length: 6,
    excludeSimilar: true,
  );

  void _refreshCaptcha() {
    setState(() {
      _captchaText = CaptchaView.generateText(
        length: 6,
        excludeSimilar: true,
      );
    });
  }

  Future<void> _showSlideVerifyDialog() async {
    final verified = await SlideVerifyView.show(
      context,
      title: 'Security Check',
      sliderText: 'Slide to match the puzzle piece',
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
          verified == true ? 'Verification Passed!' : 'Verification Cancelled',
        ),
      ),
    );
  }

  Future<void> _openSlideVerifyPage() async {
    final verified = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Slide Verify Route')),
          body: const Center(
            child: SlideVerifyView(
              title: 'Please complete verification',
              sliderText: 'Drag slider right to verify',
            ),
          ),
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          verified == true ? 'Verification Passed!' : 'Verification Failed',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('captcha_view Example'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Text Captcha (Tap to Refresh)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              CaptchaView(
                text: _captchaText,
                lineColors: CaptchaView.rainbowColors,
                lineCount: 6,
                width: 280,
                height: 50,
                onTap: _refreshCaptcha,
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
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _refreshCaptcha,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Captcha'),
              ),
              const Divider(height: 48),
              const Text(
                'Slide Puzzle Captcha',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _showSlideVerifyDialog,
                icon: const Icon(Icons.security),
                label: const Text('Show Slide Verification Dialog'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: _openSlideVerifyPage,
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open Slide Verification Route'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
