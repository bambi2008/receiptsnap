import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/tax_guide_data.dart';
import '../config/theme.dart';

class TaxGuideScreen extends StatefulWidget {
  const TaxGuideScreen({super.key});

  @override
  State<TaxGuideScreen> createState() => _TaxGuideScreenState();
}

enum _GuideSection { business, credits, pitfalls }

class _TaxGuideScreenState extends State<TaxGuideScreen> {
  static const _selectedSeasonKey = 'tax_checklist_selected_season';
  static const _reviewKeyPrefix = 'tax_checklist_reviewed_';

  late int _season;

  Box get _settings => Hive.box('settings');

  @override
  void initState() {
    super.initState();
    _season =
        _settings.get(_selectedSeasonKey, defaultValue: DateTime.now().year)
            as int;
  }

  List<int> get _seasonOptions {
    final current = DateTime.now().year;
    final seasons = <int>{
      _season,
      current - 2,
      current - 1,
      current,
      current + 1,
    };
    return seasons.toList()..sort((a, b) => b.compareTo(a));
  }

  String _reviewKey(TaxGuideEntry entry) =>
      '$_reviewKeyPrefix${_season}_${entry.checklistId}';

  bool _isReviewed(TaxGuideEntry entry) =>
      _settings.get(_reviewKey(entry), defaultValue: false) as bool;

  int _reviewedCount(List<TaxGuideEntry> entries) =>
      entries.where(_isReviewed).length;

  Future<void> _setSeason(int? season) async {
    if (season == null || season == _season) return;
    await _settings.put(_selectedSeasonKey, season);
    if (mounted) setState(() => _season = season);
  }

  Future<void> _setReviewed(TaxGuideEntry entry, bool? value) async {
    await _settings.put(_reviewKey(entry), value ?? false);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppTheme.bg,
        appBar: AppBar(
          title: const Text('Freelancer Tax Blind Spots'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Business costs'),
              Tab(text: 'Tax credits'),
              Tab(text: 'Pitfalls'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _GuideList(
              entries: const [...TaxGuideData.expenseEntries],
              section: _GuideSection.business,
              season: _season,
              seasonOptions: _seasonOptions,
              reviewedCount: _reviewedCount(TaxGuideData.expenseEntries),
              isReviewed: _isReviewed,
              onReviewedChanged: _setReviewed,
              onSeasonChanged: _setSeason,
              accent: AppTheme.green,
            ),
            _GuideList(
              entries: const [...TaxGuideData.creditEntries],
              section: _GuideSection.credits,
              season: _season,
              seasonOptions: _seasonOptions,
              reviewedCount: _reviewedCount(TaxGuideData.creditEntries),
              isReviewed: _isReviewed,
              onReviewedChanged: _setReviewed,
              onSeasonChanged: _setSeason,
              accent: AppTheme.purple,
            ),
            _GuideList(
              entries: const [...TaxGuideData.pitfallEntries],
              section: _GuideSection.pitfalls,
              season: _season,
              seasonOptions: _seasonOptions,
              reviewedCount: _reviewedCount(TaxGuideData.pitfallEntries),
              isReviewed: _isReviewed,
              onReviewedChanged: _setReviewed,
              onSeasonChanged: _setSeason,
              accent: AppTheme.orange,
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideList extends StatelessWidget {
  final List<TaxGuideEntry> entries;
  final _GuideSection section;
  final int season;
  final List<int> seasonOptions;
  final int reviewedCount;
  final bool Function(TaxGuideEntry) isReviewed;
  final Future<void> Function(TaxGuideEntry, bool?) onReviewedChanged;
  final Future<void> Function(int?) onSeasonChanged;
  final Color accent;

  const _GuideList({
    required this.entries,
    required this.section,
    required this.season,
    required this.seasonOptions,
    required this.reviewedCount,
    required this.isReviewed,
    required this.onReviewedChanged,
    required this.onSeasonChanged,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final hasSectionNote = section != _GuideSection.pitfalls;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      itemCount: entries.length + (hasSectionNote ? 3 : 2),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _ChecklistCard(
            title: section == _GuideSection.credits
                ? 'Your personal credit review'
                : 'Your tax-season blind-spot check',
            season: season,
            seasonOptions: seasonOptions,
            reviewedCount: reviewedCount,
            totalCount: entries.length,
            onSeasonChanged: onSeasonChanged,
            accent: accent,
          );
        }
        if (index == 1) return _ScopeCard(section: section);
        if (hasSectionNote && index == 2) {
          return section == _GuideSection.credits
              ? const _CreditScopeCard()
              : const _CurrentLawCard();
        }
        final entryIndex = index - (hasSectionNote ? 3 : 2);
        final entry = entries[entryIndex];
        return _GuideEntryCard(
          entry: entry,
          detailLabel: section == _GuideSection.credits
              ? 'What to verify and collect'
              : 'What the IRS guidance says',
          reviewed: isReviewed(entry),
          onReviewedChanged: (value) => onReviewedChanged(entry, value),
          accent: accent,
        );
      },
    );
  }
}

class _ChecklistCard extends StatelessWidget {
  final String title;
  final int season;
  final List<int> seasonOptions;
  final int reviewedCount;
  final int totalCount;
  final ValueChanged<int?> onSeasonChanged;
  final Color accent;

  const _ChecklistCard({
    required this.title,
    required this.season,
    required this.seasonOptions,
    required this.reviewedCount,
    required this.totalCount,
    required this.onSeasonChanged,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalCount == 0 ? 0.0 : reviewedCount / totalCount;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withValues(
          alpha: Theme.of(context).brightness == Brightness.dark ? 0.16 : 0.09,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              DropdownButton<int>(
                value: season,
                underline: const SizedBox.shrink(),
                items: seasonOptions
                    .map(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: Text('$value season'),
                      ),
                    )
                    .toList(),
                onChanged: onSeasonChanged,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$reviewedCount of $totalCount reviewed',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 7),
          LinearProgressIndicator(
            value: progress,
            minHeight: 7,
            borderRadius: BorderRadius.circular(8),
            color: accent,
            backgroundColor: accent.withValues(alpha: 0.12),
          ),
          const SizedBox(height: 12),
          const Text(
            'A check means “reviewed,” not “deductible” or “claimed.” This checklist does not promise a deduction, refund, tax savings, completeness, filing accuracy or compliance. It only helps organize your review and does not replace a qualified tax professional.',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScopeCard extends StatelessWidget {
  final _GuideSection section;

  const _ScopeCard({required this.section});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.verified_outlined, color: AppTheme.blue, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'IRS-backed lessons, not generic tips',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            section == _GuideSection.credits
                ? 'Federal personal credits that can apply to U.S. freelancers as individual taxpayers. Based on current IRS guidance; reviewed ${TaxGuideData.reviewedDate}.'
                : 'For U.S. freelancers and sole proprietors who generally file Schedule C. Based on current IRS instructions and publications; reviewed ${TaxGuideData.reviewedDate}.',
            style: const TextStyle(fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 8),
          Text(
            section == _GuideSection.credits
                ? 'A listed credit is not automatically available. Eligibility depends on household facts, filing status, income, identification numbers, timing and current law. State and local credits are outside this federal checklist.'
                : 'No item is automatically deductible. Eligibility depends on your facts, business purpose, records and current law. Specialized industries, entities, states and localities may follow other rules.',
            style: const TextStyle(
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

class _CreditScopeCard extends StatelessWidget {
  const _CreditScopeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppTheme.purple.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.purple.withValues(alpha: 0.16)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Credits are different from business deductions',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 6),
          Text(
            'A Schedule C deduction reduces business profit. A credit reduces federal income tax and some credits can increase a refund. These items usually depend on personal and household facts that cannot be inferred from a receipt, so you must review and confirm them.',
            style: TextStyle(fontSize: 12, height: 1.4),
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
  final String detailLabel;
  final bool reviewed;
  final ValueChanged<bool?> onReviewedChanged;
  final Color accent;

  const _GuideEntryCard({
    required this.entry,
    required this.detailLabel,
    required this.reviewed,
    required this.onReviewedChanged,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: accent.withValues(alpha: 0.18)),
      ),
      child: ExpansionTile(
        leading: Checkbox(
          value: reviewed,
          activeColor: accent,
          onChanged: onReviewedChanged,
        ),
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
            label: detailLabel,
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
