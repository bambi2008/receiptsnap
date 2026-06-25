import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Auto-playing animated demo showing core value props in ~30s.
/// Each step auto-advances; user can also swipe.
class AppDemo extends StatefulWidget {
  final VoidCallback onDone;

  const AppDemo({super.key, required this.onDone});

  @override
  State<AppDemo> createState() => _AppDemoState();
}

class _AppDemoState extends State<AppDemo> with TickerProviderStateMixin {
  late final PageController _pageCtrl;
  late final AnimationController _progressCtrl;
  int _page = 0;
  static const _pageCount = 4;
  static const _pageDuration = Duration(seconds: 7);

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
    _progressCtrl = AnimationController(vsync: this, duration: _pageDuration)
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed && _page < _pageCount - 1) {
          _pageCtrl.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
        }
      })
      ..forward();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: List.generate(_pageCount, (i) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: i < _pageCount - 1 ? 6 : 0),
                      decoration: BoxDecoration(
                        color: i <= _page ? AppTheme.blue : AppTheme.separator,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),
            // Pages
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                onPageChanged: (i) {
                  setState(() => _page = i);
                  _progressCtrl.reset();
                  _progressCtrl.forward();
                },
                children: const [
                  _DemoPage(
                    emoji: '💰',
                    title: 'Know What You Owe\nBefore the IRS Does',
                    subtitle: 'Quarterly tax deadlines.\nEstimated payments.\nNo surprises at tax time.',
                    color: AppTheme.blue,
                  ),
                  _DemoPage(
                    emoji: '📸',
                    title: 'Snap a Receipt.\nDone.',
                    subtitle: 'Camera opens instantly.\nAI reads vendor, amount, date.\nAuto-filed to IRS categories.',
                    color: AppTheme.green,
                  ),
                  _DemoPage(
                    emoji: '🚗',
                    title: 'Every Mile Counts.\n\$0.70 Each.',
                    subtitle: 'Log trips in seconds.\nDaily reminder so you never forget.\nIRS-compliant records.',
                    color: AppTheme.orange,
                  ),
                  _DemoPage(
                    emoji: '🛡️',
                    title: '12 Tax Mistakes\nYou Won\'t Make',
                    subtitle: 'Quarterly taxes. Mileage. Home office.\nSE tax. Deductions you\'re missing.\n\$89.99/year = less than one CPA hour.',
                    color: AppTheme.purple,
                  ),
                ],
              ),
            ),
            // Bottom buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
              child: Row(
                children: [
                  TextButton(
                    onPressed: widget.onDone,
                    child: const Text('Skip', style: TextStyle(color: AppTheme.textSecondary)),
                  ),
                  const Spacer(),
                  AnimatedBuilder(
                    animation: _progressCtrl,
                    builder: (_, child) {
                      return FilledButton.icon(
                        onPressed: _page < _pageCount - 1
                            ? () => _pageCtrl.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut)
                            : widget.onDone,
                        icon: Icon(_page < _pageCount - 1 ? Icons.arrow_forward : Icons.check, size: 20),
                        label: Text(_page < _pageCount - 1 ? 'Next (${_pageDuration.inSeconds - (_progressCtrl.value * _pageDuration.inSeconds).round()}s)' : 'Get Started'),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DemoPage extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;

  const _DemoPage({
    required this.emoji, required this.title, required this.subtitle, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 56)),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.text, height: 1.2),
          ),
          const SizedBox(height: 20),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary, height: 1.5),
          ),
        ],
      ),
    );
  }
}
