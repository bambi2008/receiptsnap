import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/receipt.dart';
import '../config/categories.dart';
import '../config/receipt_tax_insights.dart';
import '../config/theme.dart';
import '../providers/receipt_provider.dart';
import '../services/export_service.dart';
import 'tax_guide_screen.dart';

class DetailScreen extends StatefulWidget {
  final Receipt receipt;

  const DetailScreen({super.key, required this.receipt});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Receipt _receipt;

  @override
  void initState() {
    super.initState();
    _receipt = widget.receipt;
  }

  @override
  Widget build(BuildContext context) {
    final cat = categoryMap[_receipt.category] ?? categories.last;
    final taxMatch = ReceiptTaxInsights.forReceipt(_receipt);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Text(_receipt.vendorName),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Delete Receipt?'),
                  content: const Text('This cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.red,
                      ),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                if (!mounted) return;
                // ignore: use_build_context_synchronously
                final provider = context.read<ReceiptProvider>();
                // ignore: use_build_context_synchronously
                final navigator = Navigator.of(context);
                await provider.deleteReceipt(_receipt.id);
                if (!mounted) return;
                navigator.pop();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Receipt image placeholder
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: _receipt.imagePath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(_receipt.imagePath!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Center(
                          child: Text('Receipt image unavailable'),
                        ),
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 60,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Receipt Image',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 20),

            // Editable fields
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildField(
                      'Vendor',
                      _receipt.vendorName,
                      (v) => _update('vendorName', v),
                    ),
                    const Divider(),
                    _buildField(
                      'Amount',
                      _receipt.formattedAmount,
                      (v) {
                        final a = double.tryParse(v.replaceAll('\$', ''));
                        if (a != null &&
                            a.isFinite &&
                            a >= 0 &&
                            a <= 10000000) {
                          _update('amount', a);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Enter an amount from 0 to 10,000,000.',
                              ),
                            ),
                          );
                        }
                      },
                      keyboardType: TextInputType.number,
                    ),
                    const Divider(),
                    _buildCategoryField(cat),
                    const Divider(),
                    _buildDateField(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            _buildTaxReviewCard(taxMatch),
            const SizedBox(height: 20),

            // Export buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final path = await ExportService.exportCsv([_receipt]);
                      if (path != null && mounted) {
                        await Share.shareXFiles([XFile(path)]);
                      }
                    },
                    icon: const Icon(Icons.table_chart_outlined, size: 18),
                    label: const Text('CSV'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () async {
                      final path = await ExportService.exportPdf([_receipt]);
                      if (path != null && mounted) {
                        await Share.shareXFiles([XFile(path)]);
                      }
                    },
                    icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                    label: const Text('PDF'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaxReviewCard(ReceiptTaxMatch match) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.indigo.withValues(alpha: 0.20)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.indigo.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline, color: AppTheme.indigo),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Tax blind spots for this receipt',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _TaxInsightBlock(
            icon: match.needsManualReview
                ? Icons.help_outline
                : Icons.savings_outlined,
            eyebrow: match.needsManualReview
                ? 'MANUAL REVIEW NEEDED'
                : 'POSSIBLE EXPENSE RULE TO REVIEW',
            title: match.expenseLabel,
            body:
                match.possibleExpense?.overview ??
                'The current category is not specific enough to match a possible expense rule.',
            color: match.needsManualReview
                ? AppTheme.textSecondary
                : AppTheme.green,
          ),
          const SizedBox(height: 10),
          _TaxInsightBlock(
            icon: Icons.warning_amber_rounded,
            eyebrow: 'FREELANCER TRAP TO AVOID',
            title: match.pitfallLabel,
            body: match.pitfall.overview,
            color: AppTheme.orange,
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.blue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Do now: ${match.action}',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.blueLight
                    : AppTheme.blueDark,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'A match is a review prompt, not a determination that the expense is deductible or reportable in a particular place.',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 10,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 4),
          TextButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TaxGuideScreen()),
            ),
            icon: const Icon(Icons.menu_book_outlined, size: 17),
            label: const Text('Open all freelancer tax lessons'),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    String label,
    String value,
    Function(String) onChanged, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    final ctrl = TextEditingController(text: value);
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ),
        Expanded(
          child: TextField(
            controller: ctrl,
            keyboardType: keyboardType,
            onSubmitted: (v) {
              onChanged(v);
              context.read<ReceiptProvider>().updateReceipt(_receipt);
            },
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryField(ReceiptCategory cat) {
    return InkWell(
      onTap: () async {
        final selected = await showModalBottomSheet<String>(
          context: context,
          builder: (_) => ListView(
            children: categories
                .map(
                  (c) => ListTile(
                    leading: Icon(c.icon, color: c.color),
                    title: Text(c.label),
                    selected: c.key == _receipt.category,
                    onTap: () => Navigator.pop(context, c.key),
                  ),
                )
                .toList(),
          ),
        );
        if (selected != null && mounted) {
          _update('category', selected);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            const SizedBox(
              width: 80,
              child: Text(
                'Category',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
            Icon(cat.icon, color: cat.color, size: 20),
            const SizedBox(width: 8),
            Text(cat.label, style: const TextStyle(fontSize: 14)),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _receipt.date,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (picked != null && mounted) {
          _update('date', picked);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            const SizedBox(
              width: 80,
              child: Text(
                'Date',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
            Text(_receipt.formattedDate, style: const TextStyle(fontSize: 14)),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _update(String field, dynamic value) {
    setState(() {
      switch (field) {
        case 'vendorName':
          _receipt.vendorName = value as String;
        case 'amount':
          _receipt.amount = value as double;
        case 'category':
          _receipt.category = value as String;
        case 'date':
          _receipt.date = value as DateTime;
      }
    });
    context.read<ReceiptProvider>().updateReceipt(_receipt);
  }
}

class _TaxInsightBlock extends StatelessWidget {
  final IconData icon;
  final String eyebrow;
  final String title;
  final String body;
  final Color color;

  const _TaxInsightBlock({
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 21),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow,
                  style: TextStyle(
                    color: color,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.45,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(body, style: const TextStyle(fontSize: 12, height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
