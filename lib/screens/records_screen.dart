import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/extensions/context_theme.dart';
import '../core/storage_keys.dart';
import '../core/ui/soft_card.dart';

// ─── RecordEntry Model (UI only) ────────────────────────────

class RecordEntry {
  final DateTime date;
  final int level; // 1–10

  const RecordEntry({required this.date, required this.level});

  String get emoji => _conditionEmoji(level);
  String get label => _conditionLabel(level);

  String relativeDay(DateTime today) {
    final diff = today.difference(date).inDays;
    if (diff == 0) return '오늘';
    if (diff == 1) return '어제';
    return '$diff일 전';
  }
}

// ─── Helper Functions ───────────────────────────────────────

/// Maps internal level (1–10) to user-facing qualitative label.
String _conditionLabel(int level) {
  if (level <= 2) return '많이 힘들었어요';
  if (level <= 4) return '불편함이 있었어요';
  if (level <= 5) return '조금 불편했어요';
  if (level <= 7) return '괜찮은 편이었어요';
  if (level <= 9) return '컨디션이 좋았어요';
  return '아주 좋았어요';
}

/// Maps internal level (1–10) to an emoji face.
String _conditionEmoji(int level) {
  if (level <= 2) return '😖';
  if (level <= 4) return '😕';
  if (level <= 5) return '😐';
  if (level <= 7) return '🙂';
  if (level <= 9) return '😊';
  return '😄';
}

/// Format date range (e.g. "04.16. ~ 04.22.")
String _formatDateRange(DateTime start, DateTime end) {
  String fmt(DateTime d) =>
      '${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}.';
  return '${fmt(start)} ~ ${fmt(end)}';
}

// ─── Records Screen ─────────────────────────────────────────

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  bool _loading = true;
  bool _showInput = false;
  int _selectedTab = 0;

  // Computed once in _loadRecords, not in build()
  late DateTime _today;
  late String _dateRangeText;

  // Record state
  RecordEntry? _todayRecord;
  final List<RecordEntry> _recentRecords = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(const Duration(days: 6));

    final prefs = await SharedPreferences.getInstance();
    final savedDateStr = prefs.getString(StorageKeys.bodyConditionDate);
    final savedLevel = prefs.getInt(StorageKeys.bodyConditionLevel);

    final records = <RecordEntry>[];
    RecordEntry? todayEntry;

    if (savedDateStr != null && savedLevel != null) {
      final savedDate = DateTime.tryParse(savedDateStr);
      if (savedDate != null) {
        final entry = RecordEntry(date: savedDate, level: savedLevel);
        records.add(entry);

        final savedDay = DateTime(savedDate.year, savedDate.month, savedDate.day);
        if (savedDay == today) {
          todayEntry = entry;
        }
      }
    }

    setState(() {
      _today = today;
      _dateRangeText = _formatDateRange(weekAgo, today);
      _todayRecord = todayEntry;
      _recentRecords
        ..clear()
        ..addAll(records);
      _loading = false;
    });
  }

  Future<void> _saveRecord(int level) async {
    final prefs = await SharedPreferences.getInstance();
    final dateStr =
        '${_today.year}-${_today.month.toString().padLeft(2, '0')}-${_today.day.toString().padLeft(2, '0')}';

    await prefs.setInt(StorageKeys.bodyConditionLevel, level);
    await prefs.setString(StorageKeys.bodyConditionDate, dateStr);

    final newEntry = RecordEntry(date: _today, level: level);

    setState(() {
      _todayRecord = newEntry;
      _showInput = false;

      _recentRecords.removeWhere(
          (e) => e.date.year == _today.year &&
                 e.date.month == _today.month &&
                 e.date.day == _today.day);
      _recentRecords.insert(0, newEntry);
    });
  }

  void _onStartInput() {
    setState(() {
      _showInput = true;
    });
  }

  void _onCloseInput() {
    setState(() {
      _showInput = false;
    });
  }

  void _onTabChanged(int index) {
    setState(() {
      _selectedTab = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_showInput) {
      return _ConditionInputView(
        initialLevel: _todayRecord?.level ?? 5,
        onSave: _saveRecord,
        onBack: _onCloseInput,
      );
    }

    return Scaffold(
      backgroundColor: context.colorScheme.surfaceContainerLowest,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // Header
              Text(
                '기록',
                style: context.headlineSmall.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 20),

              // Segmented toggle
              _SegmentedToggle(
                selectedIndex: _selectedTab,
                onChanged: _onTabChanged,
              ),
              const SizedBox(height: 24),

              // Add record card (always visible)
              _AddRecordCard(onTap: _onStartInput),
              const SizedBox(height: 24),

              // Body state tab content
              if (_selectedTab == 0) ...[
                // Header row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '최근 7일',
                      style: context.titleSmall.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _dateRangeText,
                      style: context.bodySmall.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Records list or empty state
                if (_recentRecords.isEmpty)
                  const _EmptyStateCard()
                else
                  _RecordsList(records: _recentRecords, today: _today),
              ],

              // Exercise tab (placeholder)
              if (_selectedTab == 1) ...[
                const SizedBox(height: 48),
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.fitness_center_rounded,
                        size: 48,
                        color: context.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '운동 기록은 준비 중이에요',
                        style: context.titleSmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Premium teaser
              const _PremiumTeaser(),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Add Record Card ────────────────────────────────────────

class _AddRecordCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AddRecordCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      onTap: onTap,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.add_circle_outline_rounded,
              color: context.colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '오늘 몸 상태 기록하기',
                  style: context.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '하루 한 번, 가볍게 남겨보세요',
                  style: context.bodySmall.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: context.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

// ─── Segmented Toggle ───────────────────────────────────────

class _SegmentedToggle extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _SegmentedToggle({
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _ToggleButton(
            label: '몸 상태',
            isSelected: selectedIndex == 0,
            onTap: () => onChanged(0),
          ),
          _ToggleButton(
            label: '운동 기록',
            isSelected: selectedIndex == 1,
            onTap: () => onChanged(1),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? context.colorScheme.surface
                : context.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: context.bodyMedium.copyWith(
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? context.colorScheme.onSurface
                  : context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Empty State Card ───────────────────────────────────────

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard();

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: [
          const SizedBox(
            height: 48,
            child: FittedBox(child: Text('🌱')),
          ),
          const SizedBox(height: 16),
          Text(
            '아직 기록이 없어요',
            style: context.titleSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            '필요할 때 가볍게 남겨보세요',
            style: context.bodySmall.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Records List ───────────────────────────────────────────

class _RecordsList extends StatelessWidget {
  final List<RecordEntry> records;
  final DateTime today;

  const _RecordsList({required this.records, required this.today});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '최근 몸 상태 기록',
          style: context.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        ...records.take(7).map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SoftCard(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: Text(
                      entry.relativeDay(today),
                      style: context.bodySmall.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 36,
                    child: FittedBox(
                      child: Text(entry.emoji),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.label,
                      style: context.titleSmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ─── Premium Teaser ─────────────────────────────────────────

class _PremiumTeaser extends StatelessWidget {
  const _PremiumTeaser();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '프리미엄 기능',
              style: context.titleSmall.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: context.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'PREMIUM',
                style: context.bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SoftCard(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: context.colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.insights_rounded,
                  color: context.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '회복 흐름 인사이트',
                      style: context.titleSmall.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '기록을 바탕으로 회복 흐름을 확인할 수 있어요.',
                      style: context.bodySmall.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Condition Input View (Slider-based) ────────────────────

/// Maps slider value (0–9) to emoji.
String _sliderEmoji(double value) {
  if (value < 2) return '😖';
  if (value < 4) return '😣';
  if (value < 6) return '😐';
  if (value < 8) return '🙂';
  return '😄';
}

/// Maps slider value (0–9) to text label.
String _sliderLabel(double value) {
  if (value < 2) return '많이 힘들었어요';
  if (value < 4) return '불편했어요';
  if (value < 6) return '보통이에요';
  if (value < 8) return '괜찮은 편이에요';
  return '편안했어요';
}

class _ConditionInputView extends StatefulWidget {
  final int initialLevel;
  final Future<void> Function(int) onSave;
  final VoidCallback onBack;

  const _ConditionInputView({
    required this.initialLevel,
    required this.onSave,
    required this.onBack,
  });

  @override
  State<_ConditionInputView> createState() => _ConditionInputViewState();
}

class _ConditionInputViewState extends State<_ConditionInputView> {
  late double _sliderValue;
  bool _hasInteracted = false;

  @override
  void initState() {
    super.initState();
    _sliderValue = (widget.initialLevel - 1).toDouble();
  }

  int _toStorageValue() => _sliderValue.round() + 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surfaceContainerLowest,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Back button
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: widget.onBack,
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: context.colorScheme.onSurface,
                  ),
                ),
              ),
              const Spacer(flex: 2),

              // Dynamic emoji — large
              SizedBox(
                height: 80,
                child: FittedBox(
                  child: Text(_sliderEmoji(_sliderValue)),
                ),
              ),
              const SizedBox(height: 16),

              // Dynamic text label
              Text(
                _sliderLabel(_sliderValue),
                style: context.titleLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Question
              Text(
                '오늘 느껴지는 몸 상태는\n어느 정도인가요?',
                style: context.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Slider with emoji anchors
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 32,
                      child: FittedBox(child: Text('😖')),
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: context.colorScheme.primary,
                          inactiveTrackColor:
                              context.colorScheme.surfaceContainerHighest,
                          thumbColor: context.colorScheme.primary,
                          overlayColor:
                              context.colorScheme.primary.withValues(alpha: 0.12),
                          trackHeight: 8,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 14,
                          ),
                        ),
                        child: Slider(
                          value: _sliderValue,
                          min: 0,
                          max: 9,
                          onChanged: (value) {
                            setState(() {
                              _sliderValue = value;
                              _hasInteracted = true;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 32,
                      child: FittedBox(child: Text('😄')),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Instruction text
              Text(
                '본인 기준으로\n편하게 조절해주세요',
                style: context.bodySmall.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 3),

              // Save button (enabled only after interaction)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _hasInteracted
                      ? () => widget.onSave(_toStorageValue())
                      : null,
                  child: const Text('저장하기'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
