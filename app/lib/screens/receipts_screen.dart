import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../providers/receipt_provider.dart';
import '../config/categories.dart';
import '../config/theme.dart';
import '../models/receipt.dart';
import 'detail_screen.dart';

class ReceiptsScreen extends StatefulWidget {
  const ReceiptsScreen({super.key});

  @override
  State<ReceiptsScreen> createState() => _ReceiptsScreenState();
}

class _ReceiptsScreenState extends State<ReceiptsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReceiptProvider>();
    final receipts = provider.search(_query);
    final grouped = _groupByMonth(receipts);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: const Text('Receipts')),
      body: Column(
        children: [
          _buildSummaryCard(provider),
          if (receipts.isEmpty)
            _buildEmptyState()
          else ...[
            _buildSearchBar(),
            ...grouped.entries.map((e) => _buildMonthSection(e.key, e.value)),
            const SizedBox(height: 80),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: AppTheme.blue.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.receipt_long_outlined, size: 40, color: AppTheme.blue),
            ),
            const SizedBox(height: 20),
            const Text('No receipts — yet.',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.text)),
            const SizedBox(height: 8),
            const Text(
              'Every coffee run, software subscription,\nand office supply adds up.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: AppTheme.textSecondary, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(ReceiptProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.blue, AppTheme.blueDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppTheme.blue.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('THIS MONTH', style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1)),
          const SizedBox(height: 4),
          Text('${provider.monthlyCount} receipts', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          Text('\$${provider.monthlyTotal.toStringAsFixed(2)} in deductions',
              style: const TextStyle(color: Colors.white70, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => setState(() => _query = v),
        decoration: InputDecoration(
          hintText: 'Search receipts',
          prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildMonthSection(String month, List<Receipt> receipts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
          child: Text(month, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary, letterSpacing: 0.5)),
        ),
        ...receipts.map((r) => _buildReceiptCard(r)),
      ],
    );
  }

  Widget _buildReceiptCard(Receipt receipt) {
    final cat = categoryMap[receipt.category] ?? categories.last;
    return Slidable(
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _editCategory(receipt),
            backgroundColor: AppTheme.blue,
            foregroundColor: Colors.white,
            icon: Icons.category,
            label: 'Category',
          ),
          SlidableAction(
            onPressed: (_) => context.read<ReceiptProvider>().deleteReceipt(receipt.id),
            backgroundColor: AppTheme.red,
            foregroundColor: Colors.white,
            icon: Icons.delete_outline,
            label: 'Delete',
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
        child: Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(receipt: receipt)));
            },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: cat.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(cat.icon, color: cat.color, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(receipt.vendorName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                        const SizedBox(height: 2),
                        Text(receipt.formattedDate, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                  Text(receipt.formattedAmount,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppTheme.text)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _editCategory(Receipt receipt) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => ListView(
        children: categories.map((c) => ListTile(
          leading: Icon(c.icon, color: c.color),
          title: Text(c.label),
          selected: c.key == receipt.category,
          onTap: () => Navigator.pop(context, c.key),
        )).toList(),
      ),
    );
    if (selected != null && selected != receipt.category) {
      receipt.category = selected;
      if (!mounted) return;
      await context.read<ReceiptProvider>().updateReceipt(receipt);
    }
  }

  Map<String, List<Receipt>> _groupByMonth(List<Receipt> receipts) {
    final map = <String, List<Receipt>>{};
    for (final r in receipts) {
      map.putIfAbsent(r.monthYearKey, () => []).add(r);
    }
    return map;
  }
}
