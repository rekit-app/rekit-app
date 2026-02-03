import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/extensions/context_theme.dart';
import '../core/storage_keys.dart';
import '../core/ui/soft_card.dart';

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

/// Relative day label for journal display.
String _relativeDay(String dateStr, String todayStr) {
  final date = DateTime.tryParse(dateStr);
  final today = DateTime.tryParse(todayStr);
  if (date == null || today == null) return dateStr;

  final diff = today.difference(date).inDays;
  if (diff == 0) return '오늘';
  if (diff == 1) return '어제';
  return '$diff일 전';
}

/// Today as yyyy-MM-dd.
String _todayString() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  bool _loading = true;
  bool _hasRecordToday = false;
  int? _todayLevel;
  bool _showInput = false;
  int _selectedLevel = 5;

  // Last 7 days records (date → level)
  final List<MapEntry<String, int>> _recentRecords = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString(StorageKeys.bodyConditionDate);
    final savedLevel = prefs.getInt(StorageKeys.bodyConditionLevel);
    final today = _todayString();

    final records = <MapEntry<String, int>>[];
    if (savedDate != null && savedLevel != null) {
      records.add(MapEntry(savedDate, savedLevel));
    }

    setState(() {
      _hasRecordToday = savedDate == today;
      _todayLevel = _hasRecordToday ? savedLevel : null;
      _recentRecords
        ..clear()
        ..addAll(records);
      _loading = false;
    });
  }

  Future<void> _saveRecord(int level) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayString();
    await prefs.setInt(StorageKeys.bodyConditionLevel, level);
    await prefs.setString(StorageKeys.bodyConditionDate, today);

    setState(() {
      _hasRecordToday = true;
      _todayLevel = level;
      _showInput = false;

      // Update recent records
      _recentRecords
        ..removeWhere((e) => e.key == today)
        ..insert(0, MapEntry(today, level));
    });
  }

  void _onStartInput() {
    setState(() {
      _showInput = true;
      _selectedLevel = _todayLevel ?? 5;
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
        initialLevel: _selectedLevel,
        onSave: _saveRecord,
        onBack: () => setState(() => _showInput = false),
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
              Text(
                '기록',
                style: context.headlineSmall.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 24),

              // Prompt card (only if no record today)
              if (!_hasRecordToday)
                SoftCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.edit_note_rounded,
                        size: 40,
                        color: context.colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '오늘 몸 상태를\n기록해볼까요?',
                        style: context.titleLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '하루 한 번, 간단하게 체크해요',
                        style: context.bodyMedium.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _onStartInput,
                          child: const Text('오늘 상태 기록하기'),
                        ),
                      ),
                    ],
                  ),
                ),

              if (!_hasRecordToday && _recentRecords.isNotEmpty)
                const SizedBox(height: 24),

              // Journal entries
              if (_recentRecords.isNotEmpty) ...[
                Text(
                  '최근 기록',
                  style: context.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                ..._recentRecords.map((entry) {
                  final today = _todayString();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SoftCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          Text(
                            _conditionEmoji(entry.value),
                            style: const TextStyle(fontSize: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _relativeDay(entry.key, today),
                                  style: context.bodySmall.copyWith(
                                    color: context.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _conditionLabel(entry.value),
                                  style: context.titleSmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],

              // Empty state
              if (_recentRecords.isEmpty && _hasRecordToday == false) ...[
                const SizedBox(height: 48),
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.menu_book_rounded,
                        size: 48,
                        color: context.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '아직 기록이 없어요',
                        style: context.titleSmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '필요할 때 가볍게 남겨보세요',
                        style: context.bodySmall.copyWith(
                          color: context.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Condition Input View ───────────────────────────────────

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
  late int _level;

  static const _emojis = ['😖', '😣', '😕', '😕', '😐', '🙂', '🙂', '😊', '😊', '😄'];

  @override
  void initState() {
    super.initState();
    _level = widget.initialLevel;
  }

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

              // Current emoji — large
              Text(
                _emojis[_level - 1],
                style: const TextStyle(fontSize: 72),
              ),
              const SizedBox(height: 16),

              Text(
                _conditionLabel(_level),
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
              const SizedBox(height: 8),
              Text(
                '본인 기준으로 편하게 선택해주세요',
                style: context.bodySmall.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Horizontal emoji selector
              SoftCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(10, (index) {
                    final level = index + 1;
                    final isSelected = _level == level;
                    return GestureDetector(
                      onTap: () => setState(() => _level = level),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? context.colorScheme.primary
                              : context.colorScheme.surfaceContainerHigh,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontSize: isSelected ? 16 : 12,
                            ),
                            child: Text(_emojis[index]),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const Spacer(flex: 3),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => widget.onSave(_level),
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
