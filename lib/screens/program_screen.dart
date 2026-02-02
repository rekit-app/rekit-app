import 'package:flutter/material.dart';
import '../core/extensions/context_theme.dart';
import '../core/utils/storage_helper.dart';
import '../features/diagnosis/data/programs.dart';
import '../core/ui/soft_card.dart';

class ProgramScreen extends StatefulWidget {
  final String diagnosisCode;
  final int day;
  final int stage;

  const ProgramScreen({
    super.key,
    required this.diagnosisCode,
    required this.day,
    required this.stage,
  });

  @override
  State<ProgramScreen> createState() => _ProgramScreenState();
}

class _ProgramScreenState extends State<ProgramScreen> {
  late String diagnosisCode;
  late int day;
  late int stage;

  int currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    // widget에서 값 가져오기 (prefs 접근 금지)
    diagnosisCode = widget.diagnosisCode;
    day = widget.day;
    stage = widget.stage;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeDay() async {
    if (diagnosisCode.isEmpty) return;

    // ProgramScreen 책임: day +1만 수행
    await advanceDay(increment: 1);

    if (!mounted) return;

    // Stage 완료 판단은 HomeScreen에서 처리
    Navigator.pop(context);
  }

  void _onPrevious() {
    if (currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onNext() {
    final routine = programs[diagnosisCode]?[stage] ?? [];
    if (currentIndex < routine.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final routine = programs[diagnosisCode]?[stage] ?? [];

    if (routine.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('프로그램을 불러올 수 없습니다')),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            LinearProgressIndicator(
              value: (currentIndex + 1) / routine.length,
              minHeight: 4,
              backgroundColor: context.colorScheme.surface,
            ),

            // Top Bar
            _TopBar(day: day),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: routine.length,
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _ExercisePage(
                    exercise: routine[index],
                    currentIndex: index,
                    totalCount: routine.length,
                  );
                },
              ),
            ),

            // Bottom Navigation
            _BottomNavigation(
              currentIndex: currentIndex,
              totalCount: routine.length,
              onPrevious: _onPrevious,
              onNext: _onNext,
              onComplete: _completeDay,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── _TopBar ────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final int day;

  const _TopBar({required this.day});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Text(
            'Day $day',
            style: context.textTheme.titleMedium,
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {}, // empty
          ),
        ],
      ),
    );
  }
}

// ─── _ExercisePage ──────────────────────────────────────────

class _ExercisePage extends StatelessWidget {
  final String exercise;
  final int currentIndex;
  final int totalCount;

  const _ExercisePage({
    required this.exercise,
    required this.currentIndex,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // 운동 이름
          Text(
            exercise,
            style: context.textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),

          // 설명 (placeholder)
          Text(
            '어깨 근육을 부드럽게 이완합니다',
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 32),

          // Video Placeholder
          SoftCard(
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: context.colorScheme.surface,
                child: Center(
                  child: Icon(
                    Icons.play_circle_outline,
                    size: 64,
                    color: context.colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Page Indicator
          Center(
            child: _PageIndicator(
              currentIndex: currentIndex,
              totalCount: totalCount,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── _PageIndicator ─────────────────────────────────────────

class _PageIndicator extends StatelessWidget {
  final int currentIndex;
  final int totalCount;

  const _PageIndicator({
    required this.currentIndex,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalCount, (index) {
        final isActive = index == currentIndex;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? context.colorScheme.primary
                : context.colorScheme.outlineVariant,
          ),
        );
      }),
    );
  }
}

// ─── _BottomNavigation ──────────────────────────────────────

class _BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final int totalCount;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onComplete;

  const _BottomNavigation({
    required this.currentIndex,
    required this.totalCount,
    required this.onPrevious,
    required this.onNext,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final isLastPage = currentIndex == totalCount - 1;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        24 + MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        children: [
          // 이전 버튼
          IconButton(
            icon: const Icon(Icons.chevron_left),
            iconSize: 32,
            onPressed: currentIndex > 0 ? onPrevious : null,
          ),
          const SizedBox(width: 16),

          // 메인 CTA
          Expanded(
            child: ElevatedButton(
              onPressed: isLastPage ? onComplete : onNext,
              child: Text(
                isLastPage ? '오늘 완료' : '다음 단계로',
                style: context.textTheme.titleMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
