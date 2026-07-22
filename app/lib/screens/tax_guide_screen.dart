import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/tax_guide_data.dart';
import '../config/theme.dart';

class TaxGuideScreen extends StatelessWidget {
  const TaxGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.bg,
        appBar: AppBar(
          title: const Text('Tax Guide'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Possible deductions'),
              Tab(text: 'Common pitfalls'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _GuideList(
              entries: TaxGuideData.expenseEntries,
              showIntroduction: true,
            ),
            _GuideList(entries: TaxGuideData.pitfallEntries),
          ],
        ),
      ),
    );
  }
}

class _GuideList extends StatelessWidget {
  final List<TaxGuideEntry> entries;
  final bool showIntroduction;

  const _GuideList({required this.entries, this.showIntroduction = false});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      itemCount: entries.length + (showIntroduction ? 2 : 1),
      itemBuilder: (context, index) {
        if (index == 0) return const _ScopeCard();
        if (showIntroduction && index == 1) return const _CurrentLawCard();
        final entryIndex = index - (showIntroduction ? 2 : 1);
        return _GuideEntryCard(entry: entries[entryIndex]);
      },
    );
  }
}

class _ScopeCard extends StatelessWidget {
  const _ScopeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.blue.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.blue.withValues(alpha: 0.18)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified_outlined, color: AppTheme.blue, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Source-backed federal guidance',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'For U.S. freelancers and sole proprietors who generally file Schedule C. Based on current IRS instructions and publications; reviewed ${TaxGuideData.reviewedDate}.',
            style: TextStyle(fontSize: 13, height: 1.4),
          ),
          SizedBox(height: 8),
          Text(
            'No item is automatically deductible. Eligibility depends on your facts, business purpose, records and current law. Specialized industries, entities, states and localities may follow other rules.',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentLawCard extends StatelessWidget {
  const _CurrentLawCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppTheme.orange.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '2026 changes included',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 6),
          Text(
            'The guide reflects the midyear business-mileage increase (72.5¢ to 76¢), 2026 Section 179 limits, current 100% bonus-depreciation rules and 2026 QBI changes.',
            style: TextStyle(fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _GuideEntryCard extends StatelessWidget {
  final TaxGuideEntry entry;

  const _GuideEntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Text(
          entry.title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(entry.overview),
        ),
        children: [
          const Divider(),
          _DetailBlock(
            icon: Icons.check_circle_outline,
            label: 'What the IRS guidance says',
            text: entry.details,
            color: AppTheme.green,
          ),
          const SizedBox(height: 12),
          _DetailBlock(
            icon: Icons.warning_amber_rounded,
            label: 'Watch for',
            text: entry.pitfall,
            color: AppTheme.orange,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => launchUrl(
                Uri.parse(entry.sourceUrl),
                mode: LaunchMode.externalApplication,
              ),
              icon: const Icon(Icons.open_in_new, size: 17),
              label: Text(entry.sourceTitle),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailBlock extends StatelessWidget {
  final IconData icon;
  final String label;
  final String text;
  final Color color;

  const _DetailBlock({
    required this.icon,
    required this.label,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(icon, color: color, size: 19),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 3),
              Text(text, style: const TextStyle(fontSize: 13, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}
