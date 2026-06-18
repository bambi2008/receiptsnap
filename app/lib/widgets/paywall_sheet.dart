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

  @override
  Widget build(BuildContext context) {
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
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),

          // Icon + title
          const Icon(Icons.auto_awesome, size: 40, color: AppTheme.blue),
          const SizedBox(height: 12),
          const Text('SnapDeduct Pro', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Everything you need for tax-ready receipts',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 15), textAlign: TextAlign.center),
          const SizedBox(height: 24),

          // Features list
          ..._features.map((f) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: AppTheme.green, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(f, style: const TextStyle(fontSize: 15))),
              ],
            ),
          )),
          const SizedBox(height: 20),

          // Plan selector
          Row(
            children: [
              Expanded(child: _buildPlanOption(
                'Monthly',
                '\$${AppConstants.monthlyPrice.toStringAsFixed(2)}/mo',
                !_isAnnual,
              )),
              const SizedBox(width: 12),
              Expanded(child: _buildPlanOption(
                'Annual',
                '\$${(AppConstants.annualPrice / 12).toStringAsFixed(2)}/mo',
                _isAnnual,
                saveBadge: 'Save 33%',
              )),
            ],
          ),
          const SizedBox(height: 20),

          // Subscribe button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: _subscribe,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                'Subscribe \$${_isAnnual ? (AppConstants.annualPrice / 12).toStringAsFixed(2) : AppConstants.monthlyPrice.toStringAsFixed(2)}/mo',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _isAnnual ? '\$${AppConstants.annualPrice.toStringAsFixed(2)}/year' : 'Billed monthly',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  static const _features = [
    'Unlimited receipt scans',
    'CSV & PDF export',
    'Schedule C categories',
    'Priority support',
  ];

  Widget _buildPlanOption(String label, String price, bool selected, {String? saveBadge}) {
    return GestureDetector(
      onTap: () => setState(() => _isAnnual = label == 'Annual'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: selected ? AppTheme.blue : AppTheme.separator, width: selected ? 2 : 1),
          borderRadius: BorderRadius.circular(12),
          color: selected ? AppTheme.blue.withValues(alpha: 0.05) : null,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 4),
                Text(price, style: TextStyle(color: selected ? AppTheme.blue : AppTheme.textSecondary, fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
            if (saveBadge != null)
              Positioned(
                top: -22,
                right: -14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(saveBadge, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _subscribe() {
    final productId = _isAnnual ? AppConstants.proAnnualId : AppConstants.proMonthlyId;
    context.read<SubscriptionProvider>().purchase(productId);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Welcome to Pro! 🎉'),
        backgroundColor: AppTheme.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
