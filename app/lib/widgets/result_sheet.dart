import 'package:flutter/material.dart';
import '../models/receipt.dart';
import '../config/categories.dart';
import '../config/receipt_tax_insights.dart';
import '../config/theme.dart';

class ResultSheet extends StatefulWidget {
  final String imagePath;
  final String vendorName;
  final double amount;
  final String category;
  final DateTime date;

  const ResultSheet({
    super.key,
    required this.imagePath,
    required this.vendorName,
    required this.amount,
    required this.category,
    required this.date,
  });

  @override
  State<ResultSheet> createState() => _ResultSheetState();
}

class _ResultSheetState extends State<ResultSheet> {
  late String _vendor;
  late double _amount;
  late String _category;
  late DateTime _date;
  late TextEditingController _vendorCtrl;
  late TextEditingController _amountCtrl;

  @override
  void initState() {
    super.initState();
    _vendor = widget.vendorName;
    _amount = widget.amount;
    _category = widget.category;
    _date = widget.date;
    _vendorCtrl = TextEditingController(text: _vendor);
    _amountCtrl = TextEditingController(text: _amount.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _vendorCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taxMatch = ReceiptTaxInsights.forReceipt(
      Receipt(
        vendorName: _vendor,
        amount: _amount,
        date: _date,
        category: _category,
      ),
    );
    return DraggableScrollableSheet(
      initialChildSize: 0.58,
      minChildSize: 0.3,
      maxChildSize: 0.7,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            children: [
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
              const SizedBox(height: 16),
              const Text(
                'Receipt Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildField('Vendor', _vendorCtrl, (v) => _vendor = v),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      'Amount',
                      _amountCtrl,
                      (v) => _amount = double.tryParse(v) ?? _amount,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: _buildCategoryPicker()),
                ],
              ),
              const SizedBox(height: 16),
              _buildDatePicker(),
              const SizedBox(height: 12),
              const Text(
                'Category suggestions help organize records and are not tax advice. Verify tax treatment before filing.',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.indigo.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.indigo.withValues(alpha: 0.16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TAX REVIEW PROMPTS',
                      style: TextStyle(
                        color: AppTheme.indigo,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.45,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _MatchRow(
                      icon: taxMatch.needsManualReview
                          ? Icons.help_outline
                          : Icons.savings_outlined,
                      text: taxMatch.expenseLabel,
                      color: taxMatch.needsManualReview
                          ? AppTheme.textSecondary
                          : AppTheme.green,
                    ),
                    const SizedBox(height: 6),
                    _MatchRow(
                      icon: Icons.warning_amber_rounded,
                      text: taxMatch.pitfallLabel,
                      color: AppTheme.orange,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.check, size: 20),
                    label: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl,
    Function(String) onChanged, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            isDense: true,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryPicker() {
    final cat = categoryMap[_category] ?? categories.last;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () async {
            final selected = await showModalBottomSheet<String>(
              context: context,
              builder: (_) => ListView(
                children: categories
                    .map(
                      (c) => ListTile(
                        leading: Icon(c.icon, color: c.color),
                        title: Text(c.label),
                        selected: c.key == _category,
                        onTap: () => Navigator.pop(context, c.key),
                      ),
                    )
                    .toList(),
              ),
            );
            if (selected != null) setState(() => _category = selected);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(cat.icon, color: cat.color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(cat.label, style: const TextStyle(fontSize: 14)),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _date,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (picked != null) setState(() => _date = picked);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  '${_date.month}/${_date.day}/${_date.year}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _save() {
    final parsedAmount = double.tryParse(_amountCtrl.text.trim());
    if (_vendorCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vendor is required.')));
      return;
    }
    if (parsedAmount == null ||
        !parsedAmount.isFinite ||
        parsedAmount < 0 ||
        parsedAmount > 10000000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter an amount from 0 to 10,000,000.')),
      );
      return;
    }
    final receipt = Receipt(
      vendorName: _vendorCtrl.text.trim(),
      amount: parsedAmount,
      date: _date,
      category: _category,
      imagePath: widget.imagePath,
    );
    Navigator.pop(context, receipt);
  }
}

class _MatchRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _MatchRow({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 17),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
