import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../providers/subscription_provider.dart';

class PaywallSheet extends StatefulWidget {
  const PaywallSheet({super.key});

  @override
  State<PaywallSheet> createState() => _PaywallSheetState();
}

class _PaywallSheetState extends State<PaywallSheet> {
  bool _isAnnual = true;
  bool _isPurchasing = false;

  @override
  Widget build(BuildContext context) {
    final subscription = context.watch<SubscriptionProvider>();
    final monthly = _product(subscription, AppConstants.proMonthlyId);
    final annual = _product(subscription, AppConstants.proAnnualId);
    final selectedProduct = _isAnnual ? annual : monthly;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Icon + title
          const Icon(Icons.auto_awesome, size: 40, color: AppTheme.blue),
          const SizedBox(height: 12),
          const Text(
            'ReceiptSnap Pro',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Keep tax-time receipt records organized all year',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 15),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Features list
          ..._features.map(
            (f) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppTheme.green,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(f, style: const TextStyle(fontSize: 15)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Plan selector
          Row(
            children: [
              Expanded(
                child: _buildPlanOption(
                  'Monthly',
                  monthly == null
                      ? 'Unavailable'
                      : '${monthly.displayPrice}/month',
                  !_isAnnual,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPlanOption(
                  'Annual',
                  annual == null
                      ? 'Unavailable'
                      : '${annual.displayPrice}/year',
                  _isAnnual,
                  saveBadge: _savingsBadge(monthly, annual),
                  isBestValue: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Subscribe button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: selectedProduct == null || _isPurchasing
                  ? null
                  : _subscribe,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isPurchasing
                  ? const SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      selectedProduct == null
                          ? 'App Store unavailable'
                          : 'Subscribe for ${selectedProduct.displayPrice}${_isAnnual ? '/year' : '/month'}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Payment is charged to your Apple ID. Subscription renews automatically unless cancelled at least 24 hours before the end of the current period.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          TextButton(
            onPressed: _isPurchasing ? null : _restore,
            child: const Text('Restore Purchases'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  static const _features = [
    'Unlimited receipt scans',
    'Tax-time PDF & CSV export',
    'Reviewable expense categories',
    'Priority support',
  ];

  Widget _buildPlanOption(
    String label,
    String price,
    bool selected, {
    String? saveBadge,
    bool isBestValue = false,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _isAnnual = label == 'Annual'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected
                ? AppTheme.blue
                : isBestValue
                ? AppTheme.blue.withValues(alpha: 0.3)
                : AppTheme.separator,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: selected
              ? AppTheme.blue.withValues(alpha: 0.05)
              : isBestValue
              ? AppTheme.blue.withValues(alpha: 0.02)
              : null,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: TextStyle(
                    color: selected ? AppTheme.blue : AppTheme.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isBestValue) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'BEST VALUE',
                      style: TextStyle(
                        color: AppTheme.green,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (saveBadge != null)
              Positioned(
                top: -22,
                right: -14,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    saveBadge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _subscribe() async {
    final productId = _isAnnual
        ? AppConstants.proAnnualId
        : AppConstants.proMonthlyId;
    setState(() => _isPurchasing = true);
    final result = await context.read<SubscriptionProvider>().purchase(
      productId,
    );
    if (!mounted) return;
    setState(() => _isPurchasing = false);
    final status = result['status'];
    if (status == 'purchased') {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Welcome to ReceiptSnap Pro!'),
          backgroundColor: AppTheme.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (status != 'cancelled') {
      _showMessage(
        result['error']?.toString() ??
            (status == 'pending'
                ? 'Purchase is pending approval.'
                : 'Purchase could not be completed.'),
      );
    }
  }

  Future<void> _restore() async {
    setState(() => _isPurchasing = true);
    final result = await context
        .read<SubscriptionProvider>()
        .restorePurchases();
    if (!mounted) return;
    setState(() => _isPurchasing = false);
    if (result['status'] == 'restored') {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Purchases restored.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      _showMessage(
        result['error']?.toString() ?? 'No active subscription was found.',
      );
    }
  }

  IapProduct? _product(SubscriptionProvider provider, String id) {
    for (final product in provider.products) {
      if (product.id == id) return product;
    }
    return null;
  }

  String? _savingsBadge(IapProduct? monthly, IapProduct? annual) {
    if (monthly == null || annual == null || monthly.price <= 0) return null;
    final percent = ((1 - annual.price / (monthly.price * 12)) * 100).round();
    return percent > 0 ? 'Save $percent%' : null;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}
