import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/receipt_provider.dart';
import '../providers/subscription_provider.dart';
import '../models/receipt.dart';
import '../services/ocr_service.dart';
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

    try {
      final ocrResult = await OcrService.processImage(imagePath);

      if (mounted) {
        setState(() => _isProcessing = false);
        final result = await showModalBottomSheet<Receipt>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => ResultSheet(
            imagePath: imagePath,
            vendorName: ocrResult.vendorName,
            amount: ocrResult.amount,
            category: ocrResult.category,
            date: ocrResult.date ?? DateTime.now(),
          ),
        );

        if (result != null && mounted) {
          final receiptProvider = context.read<ReceiptProvider>();
          final subscriptionProvider = context.read<SubscriptionProvider>();
          await receiptProvider.addReceipt(result);
          subscriptionProvider.incrementReceiptCount();
          HapticFeedback.mediumImpact();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('✓ Saved. That\'s deductible.'),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      _showOcrError(e.toString());
    }
  }

  void _showOcrError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Couldn\'t read that'),
        content: Text('Try again with better lighting and a steady hand.\nBlurry receipts are tricky — even for humans.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Try again'),
          ),
        ],
      ),
    );
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
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 48,
                        height: 48,
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      Text('Reading your receipt…', style: TextStyle(color: Colors.white70, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text('This stays on your device', style: TextStyle(color: Colors.white30, fontSize: 12)),
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
