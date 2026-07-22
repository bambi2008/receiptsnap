import 'package:flutter/material.dart';
import '../config/theme.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final _slides = [
    {
      'icon': Icons.savings_outlined,
      'iconColor': AppTheme.green,
      'title': 'Stay organized for tax time',
      'subtitle':
          'Keep business receipt records together, then export them for review with your tax professional.',
    },
    {
      'icon': Icons.camera_alt_outlined,
      'iconColor': AppTheme.blue,
      'title': 'Snap, review, and save.',
      'subtitle':
          'On-device OCR extracts vendor, amount, and date and suggests a common business expense category. You verify every field.',
    },
    {
      'icon': Icons.auto_awesome,
      'iconColor': AppTheme.purple,
      'title': 'Try 50 receipts free.',
      'subtitle':
          'No credit card required. Upgrade to Pro anytime for unlimited scans and premium export.',
    },
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: widget.onComplete,
                child: const Text(
                  'Skip',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
            ),
            // Slides
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _slides.length,
                itemBuilder: (_, i) => _buildSlide(i),
              ),
            ),
            // Dots
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slides.length, (i) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: _currentPage == i ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: _currentPage == i
                          ? AppTheme.blue
                          : AppTheme.separator,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
            // Button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 48),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: _currentPage == _slides.length - 1
                      ? widget.onComplete
                      : () => _controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        ),
                  child: Text(
                    _currentPage == _slides.length - 1 ? 'Get Started' : 'Next',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide(int i) {
    final slide = _slides[i];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: (slide['iconColor'] as Color).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              slide['icon'] as IconData,
              size: 48,
              color: slide['iconColor'] as Color,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            slide['title'] as String,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppTheme.text,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            slide['subtitle'] as String,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
