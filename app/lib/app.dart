import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'config/theme.dart';
import 'config/constants.dart';
import 'screens/camera_screen.dart';
import 'screens/receipts_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/onboarding_screen.dart';

class ReceiptSnapApp extends StatelessWidget {
  const ReceiptSnapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  bool _showOnboarding = true;
  final ReceiptCaptureController _captureController =
      ReceiptCaptureController();

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  void _checkOnboarding() {
    final box = Hive.box('settings');
    final hasOnboarded = box.get(
      AppConstants.onboardingKey,
      defaultValue: false,
    );
    if (hasOnboarded) {
      setState(() => _showOnboarding = false);
    }
  }

  void _onOnboardingComplete() {
    Hive.box('settings').put(AppConstants.onboardingKey, true);
    setState(() => _showOnboarding = false);
  }

  int get _navigationIndex => switch (_currentIndex) {
    0 => 0,
    1 => 2,
    _ => 3,
  };

  Future<void> _showCaptureOptions() async {
    if (_currentIndex != 0) setState(() => _currentIndex = 0);
    final source = await showModalBottomSheet<_CaptureSource>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(8, 4, 8, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add a receipt',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Capture it now or use a photo you already have.',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              _CaptureOption(
                icon: Icons.document_scanner_outlined,
                title: 'Scan a receipt',
                subtitle: 'Open the camera',
                color: AppTheme.blue,
                onTap: () => Navigator.pop(context, _CaptureSource.camera),
              ),
              const SizedBox(height: 10),
              _CaptureOption(
                icon: Icons.photo_library_outlined,
                title: 'Choose from Photos',
                subtitle: 'Use an existing receipt image',
                color: AppTheme.purple,
                onTap: () => Navigator.pop(context, _CaptureSource.photos),
              ),
            ],
          ),
        ),
      ),
    );

    switch (source) {
      case _CaptureSource.camera:
        await _captureController.captureReceipt();
      case _CaptureSource.photos:
        await _captureController.chooseFromPhotos();
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showOnboarding) {
      return OnboardingScreen(onComplete: _onOnboardingComplete);
    }

    final screens = [
      CameraScreen(controller: _captureController),
      const ReceiptsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navigationIndex,
        onTap: (index) {
          if (index == 1) {
            _showCaptureOptions();
            return;
          }
          setState(() => _currentIndex = index == 0 ? 0 : index - 1);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: _ScanNavigationIcon(),
            activeIcon: _ScanNavigationIcon(),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Receipts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz_outlined),
            activeIcon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
      ),
    );
  }
}

enum _CaptureSource { camera, photos }

class _ScanNavigationIcon extends StatelessWidget {
  const _ScanNavigationIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 32,
      decoration: BoxDecoration(
        color: AppTheme.blue,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.blue.withValues(alpha: 0.28),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Icon(
        Icons.document_scanner_outlined,
        color: Colors.white,
        size: 21,
      ),
    );
  }
}

class _CaptureOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _CaptureOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.09),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
