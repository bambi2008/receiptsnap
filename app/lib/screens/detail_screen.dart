import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/receipt.dart';
import '../config/categories.dart';
import '../config/theme.dart';
import '../providers/receipt_provider.dart';
import '../services/export_service.dart';

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
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: FilledButton.styleFrom(backgroundColor: AppTheme.red),
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
                      child: Image.asset('assets/receipt_placeholder.png', fit: BoxFit.cover),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 60, color: Colors.grey[400]),
                        const SizedBox(height: 8),
                        Text('Receipt Image', style: TextStyle(color: Colors.grey[500])),
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
                    _buildField('Vendor', _receipt.vendorName, (v) => _update('vendorName', v)),
                    const Divider(),
                    _buildField('Amount', _receipt.formattedAmount, (v) {
                      final a = double.tryParse(v.replaceAll('\$', ''));
                      if (a != null) _update('amount', a);
                    }, keyboardType: TextInputType.number),
                    const Divider(),
                    _buildCategoryField(cat),
                    const Divider(),
                    _buildDateField(),
                  ],
                ),
              ),
            ),
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

  Widget _buildField(String label, String value, Function(String) onChanged,
      {TextInputType keyboardType = TextInputType.text}) {
    final ctrl = TextEditingController(text: value);
    return Row(
      children: [
        SizedBox(width: 80, child: Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14))),
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
            children: categories.map((c) => ListTile(
              leading: Icon(c.icon, color: c.color),
              title: Text(c.label),
              selected: c.key == _receipt.category,
              onTap: () => Navigator.pop(context, c.key),
            )).toList(),
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
            const SizedBox(width: 80, child: Text('Category', style: TextStyle(color: Colors.grey, fontSize: 14))),
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
            const SizedBox(width: 80, child: Text('Date', style: TextStyle(color: Colors.grey, fontSize: 14))),
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
        case 'vendorName': _receipt.vendorName = value as String;
        case 'amount': _receipt.amount = value as double;
        case 'category': _receipt.category = value as String;
        case 'date': _receipt.date = value as DateTime;
      }
    });
    context.read<ReceiptProvider>().updateReceipt(_receipt);
  }
}
