import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/receipt_provider.dart';
import '../providers/subscription_provider.dart';
import '../config/categories.dart';
import '../models/receipt.dart';
import '../widgets/result_sheet.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;

  Future<void> _captureReceipt() async {
    final sub = context.read<SubscriptionProvider>();
    if (sub.hasReachedLimit) {
      _showUpgradePrompt();
      return;
    }

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );
      if (photo != null && mounted) {
        await _processImage(photo.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to capture: $e')),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    final sub = context.read<SubscriptionProvider>();
    if (sub.hasReachedLimit) {
      _showUpgradePrompt();
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
      if (image != null && mounted) {
        await _processImage(image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  Future<void> _processImage(String imagePath) async {
    setState(() => _isProcessing = true);

    // Simulate OCR processing (real OCR via ML Kit in production)
    await Future.delayed(const Duration(milliseconds: 1200));

    // For demo: generate placeholder extraction
    final extracted = _simulateOcr();

    if (mounted) {
      setState(() => _isProcessing = false);
      final result = await showModalBottomSheet<Receipt>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => ResultSheet(
          imagePath: imagePath,
          vendorName: extracted['vendor']!,
          amount: extracted['amount']!,
          category: extracted['category']!,
          date: extracted['date']!,
        ),
      );

      if (result != null && mounted) {
        await context.read<ReceiptProvider>().addReceipt(result);
        HapticFeedback.mediumImpact();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Receipt saved! ✓'),
              duration: Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Map<String, dynamic> _simulateOcr() {
    final vendors = ['Starbucks', 'Adobe Creative Cloud', 'WeWork', 'Uber', 'Verizon'];
    final amounts = [4.75, 59.99, 29.00, 18.50, 89.99];
    final idx = DateTime.now().millisecond % vendors.length;
    final vendor = vendors[idx];
    return {
      'vendor': vendor,
      'amount': amounts[idx],
      'category': guessCategory(vendor),
      'date': DateTime.now(),
    };
  }

  void _showUpgradePrompt() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Free Limit Reached'),
        content: const Text('You\'ve used all 50 free receipts. Upgrade to Pro for unlimited scans.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Later')),
          FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Upgrade — \$4.99/mo')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sub = context.watch<SubscriptionProvider>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Viewfinder background
            Column(
              children: [
                const Spacer(),
                // Viewfinder frame
                Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: MediaQuery.of(context).size.height * 0.5,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white24, width: 1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Stack(
                    children: [
                      // Corner brackets
                      ...['tl', 'tr', 'bl', 'br'].map((pos) {
                        final isLeft = pos.contains('l');
                        final isTop = pos.contains('t');
                        return Positioned(
                          left: isLeft ? 0 : null,
                          right: isLeft ? null : 0,
                          top: isTop ? 0 : null,
                          bottom: isTop ? null : 0,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              border: Border(
                                left: isLeft ? const BorderSide(color: Colors.white, width: 3) : BorderSide.none,
                                right: !isLeft ? const BorderSide(color: Colors.white, width: 3) : BorderSide.none,
                                top: isTop ? const BorderSide(color: Colors.white, width: 3) : BorderSide.none,
                                bottom: !isTop ? const BorderSide(color: Colors.white, width: 3) : BorderSide.none,
                              ),
                            ),
                          ),
                        );
                      }),
                      // Free badge
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            sub.isPro ? 'Pro' : 'Free: ${sub.remainingFree}',
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                      // Placeholder receipt preview
                      const Center(
                        child: Icon(Icons.receipt_long, color: Colors.white24, size: 80),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Position receipt in frame',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const Spacer(),
                // Shutter area
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Gallery button
                      GestureDetector(
                        onTap: _pickFromGallery,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.photo_library_outlined, color: Colors.white, size: 24),
                        ),
                      ),
                      const SizedBox(width: 32),
                      // Shutter button
                      GestureDetector(
                        onTap: _captureReceipt,
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: Center(
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 64), // Spacer for symmetry
                    ],
                  ),
                ),
              ],
            ),

            // Processing overlay
            if (_isProcessing)
              Container(
                color: Colors.black87,
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                      SizedBox(height: 16),
                      Text('Reading receipt…', style: TextStyle(color: Colors.white, fontSize: 18)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
