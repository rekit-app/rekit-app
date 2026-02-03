import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/extensions/context_theme.dart';
import '../core/storage_keys.dart';
import '../core/ui/soft_card.dart';

/// Weekly question limit for premium users.
const int _weeklyQuestionLimit = 2;

/// Get current week start date (Monday).
DateTime _getWeekStart(DateTime date) {
  final weekday = date.weekday;
  return DateTime(date.year, date.month, date.day - (weekday - 1));
}

/// Format date as yyyy-MM-dd.
String _formatDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

class AskExpertScreen extends StatefulWidget {
  const AskExpertScreen({super.key});

  @override
  State<AskExpertScreen> createState() => _AskExpertScreenState();
}

class _AskExpertScreenState extends State<AskExpertScreen> {
  final _controller = TextEditingController();
  bool _loading = true;
  bool _submitting = false;

  int _questionsUsed = 0;
  int _questionsRemaining = _weeklyQuestionLimit;

  @override
  void initState() {
    super.initState();
    _loadQuestionCount();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadQuestionCount() async {
    final prefs = await SharedPreferences.getInstance();
    final savedWeekStart = prefs.getString(StorageKeys.expertQuestionWeekStart);
    final savedCount = prefs.getInt(StorageKeys.expertQuestionCount) ?? 0;

    final now = DateTime.now();
    final currentWeekStart = _getWeekStart(now);
    final currentWeekStr = _formatDate(currentWeekStart);

    int count = savedCount;

    // Reset if new week
    if (savedWeekStart != currentWeekStr) {
      count = 0;
      await prefs.setString(StorageKeys.expertQuestionWeekStart, currentWeekStr);
      await prefs.setInt(StorageKeys.expertQuestionCount, 0);
    }

    setState(() {
      _questionsUsed = count;
      _questionsRemaining = _weeklyQuestionLimit - count;
      _loading = false;
    });
  }

  Future<void> _submitQuestion() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _questionsRemaining <= 0) return;

    setState(() => _submitting = true);

    final prefs = await SharedPreferences.getInstance();

    // Save question to local list
    final questionsJson = prefs.getString(StorageKeys.expertQuestions);
    final questions = questionsJson != null
        ? List<String>.from(jsonDecode(questionsJson))
        : <String>[];
    questions.add(text);
    await prefs.setString(StorageKeys.expertQuestions, jsonEncode(questions));

    // Update count
    final newCount = _questionsUsed + 1;
    await prefs.setInt(StorageKeys.expertQuestionCount, newCount);

    setState(() {
      _questionsUsed = newCount;
      _questionsRemaining = _weeklyQuestionLimit - newCount;
      _submitting = false;
    });

    _controller.clear();

    if (!mounted) return;

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '질문이 접수되었어요. 답변이 준비되면 알려드릴게요.',
          style: context.bodySmall.copyWith(
            color: context.colorScheme.onInverseSurface,
          ),
        ),
        backgroundColor: context.colorScheme.inverseSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  bool get _canSubmit =>
      _controller.text.trim().isNotEmpty &&
      _questionsRemaining > 0 &&
      !_submitting;

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: context.colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: context.colorScheme.surfaceContainerLowest,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_rounded,
            color: context.colorScheme.onSurface,
          ),
        ),
        title: Text(
          '전문가에게 질문하기',
          style: context.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subtitle
              Text(
                '회복 과정에 대한 궁금한 점을 남겨주세요.',
                style: context.bodyMedium.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              // Remaining questions indicator
              SoftCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '이번 주 남은 질문',
                      style: context.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _questionsRemaining > 0
                            ? context.colorScheme.primaryContainer
                            : context.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$_questionsRemaining / $_weeklyQuestionLimit',
                        style: context.bodySmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: _questionsRemaining > 0
                              ? context.colorScheme.primary
                              : context.colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Question input
              Expanded(
                child: SoftCard(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _controller,
                    maxLength: 500,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    enabled: _questionsRemaining > 0,
                    decoration: InputDecoration(
                      hintText:
                          '예: 운동 후 뻐근함이 오래 가는데\n어떤 점을 신경 쓰면 좋을까요?',
                      hintStyle: context.bodyMedium.copyWith(
                        color: context.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.5),
                      ),
                      border: InputBorder.none,
                      counterStyle: context.bodySmall.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    style: context.bodyMedium,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Disclaimer
              Text(
                '답변은 일반적인 회복 가이드를 제공하며\n의학적 진단이나 치료를 대신하지 않습니다.',
                style: context.bodySmall.copyWith(
                  color: context.colorScheme.onSurfaceVariant
                      .withValues(alpha: 0.7),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canSubmit ? _submitQuestion : null,
                  child: _submitting
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: context.colorScheme.onPrimary,
                          ),
                        )
                      : const Text('질문 보내기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
