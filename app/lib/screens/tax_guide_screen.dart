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
        body: TabBarView(
          children: [
            _GuideList(
              entries: const [...TaxGuideData.expenseEntries],
              showIntroduction: true,
              season: _season,
              seasonOptions: _seasonOptions,
              reviewedCount: _reviewedCount(TaxGuideData.expenseEntries),
              isReviewed: _isReviewed,
              onReviewedChanged: _setReviewed,
              onSeasonChanged: _setSeason,
            ),
            _GuideList(
              entries: const [...TaxGuideData.pitfallEntries],
              season: _season,
              seasonOptions: _seasonOptions,
              reviewedCount: _reviewedCount(TaxGuideData.pitfallEntries),
              isReviewed: _isReviewed,
              onReviewedChanged: _setReviewed,
              onSeasonChanged: _setSeason,
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideList extends StatelessWidget {
  final List<TaxGuideEntry> entries;
  final bool showIntroduction;
  final int season;
  final List<int> seasonOptions;
  final int reviewedCount;
  final bool Function(TaxGuideEntry) isReviewed;
  final Future<void> Function(TaxGuideEntry, bool?) onReviewedChanged;
  final Future<void> Function(int?) onSeasonChanged;

  const _GuideList({
    required this.entries,
    required this.season,
    required this.seasonOptions,
    required this.reviewedCount,
    required this.isReviewed,
    required this.onReviewedChanged,
    required this.onSeasonChanged,
    this.showIntroduction = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      itemCount: entries.length + (showIntroduction ? 3 : 2),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _ChecklistCard(
            season: season,
            seasonOptions: seasonOptions,
            reviewedCount: reviewedCount,
            totalCount: entries.length,
            onSeasonChanged: onSeasonChanged,
          );
        }
        if (index == 1) return const _ScopeCard();
        if (showIntroduction && index == 2) return const _CurrentLawCard();
        final entryIndex = index - (showIntroduction ? 3 : 2);
        final entry = entries[entryIndex];
        return _GuideEntryCard(
          entry: entry,
          reviewed: isReviewed(entry),
          onReviewedChanged: (value) => onReviewedChanged(entry, value),
        );
      },
    );
  }
}

class _ChecklistCard extends StatelessWidget {
  final int season;
  final List<int> seasonOptions;
  final int reviewedCount;
  final int totalCount;
  final ValueChanged<int?> onSeasonChanged;

  const _ChecklistCard({
    required this.season,
    required this.seasonOptions,
    required this.reviewedCount,
    required this.totalCount,
    required this.onSeasonChanged,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalCount == 0 ? 0.0 : reviewedCount / totalCount;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Tax-season review checklist',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
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
            backgroundColor: AppTheme.blue.withValues(alpha: 0.10),
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
  final bool reviewed;
  final ValueChanged<bool?> onReviewedChanged;

  const _GuideEntryCard({
    required this.entry,
    required this.reviewed,
    required this.onReviewedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: Checkbox(value: reviewed, onChanged: onReviewedChanged),
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
