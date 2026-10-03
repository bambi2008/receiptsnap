import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/receipt_provider.dart';
import '../config/categories.dart';
import '../config/receipt_tax_insights.dart';
import '../config/theme.dart';
import '../models/receipt.dart';
import '../services/export_service.dart';
import 'detail_screen.dart';

class ReceiptsScreen extends StatefulWidget {
  const ReceiptsScreen({super.key});

  @override
  State<ReceiptsScreen> createState() => _ReceiptsScreenState();
}

class _ReceiptsScreenState extends State<ReceiptsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  bool _selectionMode = false;
  bool _isExporting = false;
  final Set<String> _selectedIds = {};

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
      appBar: _selectionMode
          ? AppBar(
              leading: IconButton(
                tooltip: 'Cancel selection',
                onPressed: _exitSelectionMode,
                icon: const Icon(Icons.close),
              ),
              title: Text('${_selectedIds.length} selected'),
              actions: [
                TextButton(
                  onPressed: receipts.isEmpty
                      ? null
                      : () => _toggleSelectAll(receipts),
                  child: Text(
                    receipts.every((r) => _selectedIds.contains(r.id))
                        ? 'Clear'
                        : 'Select all',
                  ),
                ),
              ],
            )
          : AppBar(
              title: const Text('Receipts'),
              actions: [
                TextButton.icon(
                  onPressed: provider.receipts.isEmpty
                      ? null
                      : () => setState(() => _selectionMode = true),
                  icon: const Icon(Icons.ios_share_outlined, size: 19),
                  label: const Text('Export'),
                ),
              ],
            ),
      body: provider.receipts.isEmpty
          ? _buildEmptyState()
          : ListView(
              children: [
                _buildSummaryCard(provider),
                _buildSearchBar(),
                if (receipts.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Text('No receipts match your search.'),
                    ),
                  )
                else
                  ...grouped.entries.map(
                    (e) => _buildMonthSection(e.key, e.value),
                  ),
                const SizedBox(height: 80),
              ],
            ),
      bottomNavigationBar: _selectionMode
          ? _buildBatchExportBar(provider.receipts)
          : null,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No receipts yet',
            style: TextStyle(fontSize: 18, color: Colors.grey[500]),
          ),
          const SizedBox(height: 8),
          Text(
            'Start organizing tax-time records.',
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
          ),
        ],
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
          BoxShadow(
            color: AppTheme.blue.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'THIS MONTH',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${provider.monthlyCount} receipts',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '\$${provider.monthlyTotal.toStringAsFixed(2)} in recorded business expenses',
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'For recordkeeping only — verify tax treatment before filing.',
            style: TextStyle(color: Colors.white60, fontSize: 11),
          ),
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
          child: Text(
            month,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...receipts.map((r) => _buildReceiptCard(r)),
      ],
    );
  }

  Widget _buildReceiptCard(Receipt receipt) {
    final cat = categoryMap[receipt.category] ?? categories.last;
    final taxMatch = ReceiptTaxInsights.forReceipt(receipt);
    return Slidable(
      enabled: !_selectionMode,
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
            onPressed: (_) => _confirmDelete(receipt),
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
              if (_selectionMode) {
                _toggleReceipt(receipt.id);
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailScreen(receipt: receipt),
                ),
              );
            },
            onLongPress: () {
              setState(() {
                _selectionMode = true;
                _selectedIds.add(receipt.id);
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _selectedIds.contains(receipt.id)
                          ? AppTheme.blue
                          : cat.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _selectedIds.contains(receipt.id)
                          ? Icons.check_rounded
                          : cat.icon,
                      color: _selectedIds.contains(receipt.id)
                          ? Colors.white
                          : cat.color,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          receipt.vendorName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          receipt.formattedDate,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Wrap(
                          spacing: 6,
                          runSpacing: 5,
                          children: [
                            _TaxMarker(
                              icon: taxMatch.needsManualReview
                                  ? Icons.help_outline
                                  : Icons.savings_outlined,
                              label: 'Review: ${taxMatch.expenseLabel}',
                              color: taxMatch.needsManualReview
                                  ? AppTheme.textSecondary
                                  : AppTheme.green,
                            ),
                            _TaxMarker(
                              icon: Icons.warning_amber_rounded,
                              label: taxMatch.pitfallLabel,
                              color: AppTheme.orange,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(
                    receipt.formattedAmount,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppTheme.text,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBatchExportBar(List<Receipt> allReceipts) {
    final selected = allReceipts
        .where((receipt) => _selectedIds.contains(receipt.id))
        .toList();
    return Material(
      color: Theme.of(context).cardColor,
      elevation: 14,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  key: const Key('batch_csv_export'),
                  onPressed: _isExporting || selected.isEmpty
                      ? null
                      : () => _exportSelected(selected, pdf: false),
                  icon: const Icon(Icons.table_chart_outlined, size: 18),
                  label: const Text('CSV ledger'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  key: const Key('batch_pdf_export'),
                  onPressed: _isExporting || selected.isEmpty
                      ? null
                      : () => _exportSelected(selected, pdf: true),
                  icon: _isExporting
                      ? const SizedBox(
                          width: 17,
                          height: 17,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.picture_as_pdf_outlined, size: 18),
                  label: Text(
                    selected.isEmpty
                        ? 'Select receipts'
                        : 'Tax package (${selected.length})',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleReceipt(String id) {
    setState(() {
      if (!_selectedIds.add(id)) _selectedIds.remove(id);
    });
  }

  void _toggleSelectAll(List<Receipt> visibleReceipts) {
    setState(() {
      final allSelected = visibleReceipts.every(
        (receipt) => _selectedIds.contains(receipt.id),
      );
      if (allSelected) {
        _selectedIds.removeAll(visibleReceipts.map((receipt) => receipt.id));
      } else {
        _selectedIds.addAll(visibleReceipts.map((receipt) => receipt.id));
      }
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _selectionMode = false;
      _selectedIds.clear();
    });
  }

  Future<void> _exportSelected(
    List<Receipt> receipts, {
    required bool pdf,
  }) async {
    setState(() => _isExporting = true);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            pdf
                ? 'Creating PDF evidence and CSV ledger for ${receipts.length} receipts…'
                : 'Creating CSV ledger for ${receipts.length} receipts…',
          ),
          duration: const Duration(seconds: 30),
        ),
      );
    // Let the progress state paint before image decoding starts.
    await Future<void>.delayed(Duration.zero);
    try {
      final pdfPath = pdf ? await ExportService.exportPdf(receipts) : null;
      final csvPath = await ExportService.exportCsv(receipts);
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      if (csvPath == null || (pdf && pdfPath == null)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not create the export file.')),
        );
        return;
      }
      // File creation is finished. Re-enable both choices before opening the
      // system share sheet, whose Future remains pending until it is dismissed.
      setState(() => _isExporting = false);
      final box = context.findRenderObject() as RenderBox?;
      final origin = box == null
          ? null
          : box.localToGlobal(Offset.zero) & box.size;
      try {
        await Share.shareXFiles(
          [
            if (pdfPath != null) XFile(pdfPath, mimeType: 'application/pdf'),
            XFile(csvPath, mimeType: 'text/csv'),
          ],
          subject: pdf
              ? 'Freelance Tax Kit self-employed tax records package'
              : 'Freelance Tax Kit self-employed expense ledger',
          sharePositionOrigin: origin,
        );
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'The share sheet could not open. Please try again.',
              ),
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  void _editCategory(Receipt receipt) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => ListView(
        children: categories
            .map(
              (c) => ListTile(
                leading: Icon(c.icon, color: c.color),
                title: Text(c.label),
                selected: c.key == receipt.category,
                onTap: () => Navigator.pop(context, c.key),
              ),
            )
            .toList(),
      ),
    );
    if (selected != null && selected != receipt.category) {
      receipt.category = selected;
      if (!mounted) return;
      await context.read<ReceiptProvider>().updateReceipt(receipt);
    }
  }

  Future<void> _confirmDelete(Receipt receipt) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete receipt?'),
        content: Text('Delete ${receipt.vendorName} and its saved image?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<ReceiptProvider>().deleteReceipt(receipt.id);
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

class _TaxMarker extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _TaxMarker({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
