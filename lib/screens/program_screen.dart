import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/extensions/context_theme.dart';
import '../core/storage_keys.dart';
import '../core/utils/storage_helper.dart';
import '../features/diagnosis/data/programs.dart';
import '../core/ui/soft_card.dart';

class ProgramScreen extends StatefulWidget {
  const ProgramScreen({super.key});

  @override
  State<ProgramScreen> createState() => _ProgramScreenState();
}

class _ProgramScreenState extends State<ProgramScreen>
    with TickerProviderStateMixin {
  String? diagnosisCode;
  int day = 1;
  int stage = 1;
  bool isLoading = true;

  int currentIndex = 0;
  late PageController _pageController;

  // Timer configuration
  static const int exerciseDurationMs = 30000; // 30 seconds
  static const int autoAdvanceDelayMs = 5000; // 5 seconds

  // Smooth timer animation
  late AnimationController _timerController;
  late Animation<double> _timerAnimation;

  // Auto-advance state
  bool _showAutoAdvanceOverlay = false;
  late AnimationController _autoAdvanceController;
  late Animation<double> _autoAdvanceAnimation;

  // Total routine time
  int _totalRemainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    // Smooth circular timer (no ticks)
    _timerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: exerciseDurationMs),
    );
    _timerAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _timerController, curve: Curves.linear),
    );
    _timerController.addStatusListener(_onTimerComplete);

    // Auto-advance progress animation
    _autoAdvanceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: autoAdvanceDelayMs),
    );
    _autoAdvanceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _autoAdvanceController, curve: Curves.linear),
    );
    _autoAdvanceController.addStatusListener(_onAutoAdvanceComplete);

    _loadProgress();
  }

  void _onTimerComplete(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _showAutoAdvance();
    }
  }

  void _onAutoAdvanceComplete(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _hideAutoAdvanceAndProceed();
    }
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();

    final dx = prefs.getString(StorageKeys.diagnosisCode);
    final d = prefs.getInt(StorageKeys.day) ?? 1;
    final s = prefs.getInt(StorageKeys.stage) ?? 1;

    if (!mounted) return;

    setState(() {
      diagnosisCode = dx;
      day = d;
      stage = s;
      isLoading = false;
    });

    _calculateTotalTime();
    _startExerciseTimer();
  }

  void _calculateTotalTime() {
    final routine = programs[diagnosisCode]?[stage] ?? [];
    final remainingExercises = routine.length - currentIndex;
    _totalRemainingSeconds = remainingExercises * (exerciseDurationMs ~/ 1000);
  }

  void _startExerciseTimer() {
    _timerController.reset();
    _timerController.forward();

    // Update total time periodically
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _showAutoAdvanceOverlay) {
        timer.cancel();
        return;
      }
      if (_totalRemainingSeconds > 0) {
        setState(() {
          _totalRemainingSeconds--;
        });
      }
      if (_timerController.status == AnimationStatus.completed) {
        timer.cancel();
      }
    });
  }

  void _showAutoAdvance() {
    setState(() {
      _showAutoAdvanceOverlay = true;
    });
    _autoAdvanceController.reset();
    _autoAdvanceController.forward();
  }

  void _hideAutoAdvanceAndProceed() {
    _autoAdvanceController.stop();
    setState(() {
      _showAutoAdvanceOverlay = false;
    });
    _goToNext();
  }

  void _cancelAutoAdvance() {
    _autoAdvanceController.stop();
    _autoAdvanceController.reset();
    setState(() {
      _showAutoAdvanceOverlay = false;
    });
    _startExerciseTimer();
  }

  @override
  void dispose() {
    _timerController.dispose();
    _autoAdvanceController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeDay() async {
    if (diagnosisCode == null || diagnosisCode!.isEmpty) return;

    final enteredStage2 = await advanceDay(increment: 1);

    if (!mounted) return;

    Navigator.pop(context, enteredStage2);
  }

  void _goToPrevious() {
    if (currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToNext() {
    final routine = programs[diagnosisCode]?[stage] ?? [];
    if (currentIndex < routine.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeDay();
    }
  }

  void _onPageChanged(int index) {
    _timerController.stop();
    _autoAdvanceController.stop();

    setState(() {
      currentIndex = index;
      _showAutoAdvanceOverlay = false;
    });

    _calculateTotalTime();
    _startExerciseTimer();
  }

  void _handleDoubleTap() {
    _timerController.stop();
    _autoAdvanceController.stop();
    setState(() {
      _showAutoAdvanceOverlay = false;
    });
    _goToNext();
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || diagnosisCode == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final routine = programs[diagnosisCode]?[stage] ?? [];

    if (routine.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('프로그램을 불러올 수 없습니다')),
      );
    }

    final currentExercise = routine[currentIndex];
    final nextExercise =
        currentIndex < routine.length - 1 ? routine[currentIndex + 1] : null;
    final isLastExercise = currentIndex == routine.length - 1;

    return Scaffold(
      body: GestureDetector(
        onDoubleTap: _handleDoubleTap,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  // Top: Progress bar
                  LinearProgressIndicator(
                    value: (currentIndex + 1) / routine.length,
                    minHeight: 4,
                    backgroundColor: context.colorScheme.surfaceContainerHighest,
                  ),

                  // Top Bar with time
                  _TopBar(
                    day: day,
                    currentIndex: currentIndex,
                    totalCount: routine.length,
                    totalRemainingTime: _formatTime(_totalRemainingSeconds),
                  ),

                  // Center: Exercise content
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: routine.length,
                      onPageChanged: _onPageChanged,
                      itemBuilder: (context, index) {
                        return _ExerciseContent(
                          exercise: routine[index],
                          timerAnimation: _timerAnimation,
                        );
                      },
                    ),
                  ),

                  // Bottom: Up Next preview
                  _BottomSection(
                    currentExercise: currentExercise,
                    nextExercise: nextExercise,
                    isLastExercise: isLastExercise,
                    onPrevious: currentIndex > 0 ? _goToPrevious : null,
                  ),
                ],
              ),
            ),

            // Auto-advance overlay (calm, no numbers)
            if (_showAutoAdvanceOverlay)
              _CalmTransitionOverlay(
                progressAnimation: _autoAdvanceAnimation,
                nextExercise: nextExercise,
                isLastExercise: isLastExercise,
                onHold: _cancelAutoAdvance,
                onSkip: _hideAutoAdvanceAndProceed,
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
  final int currentIndex;
  final int totalCount;
  final String totalRemainingTime;

  const _TopBar({
    required this.day,
    required this.currentIndex,
    required this.totalCount,
    required this.totalRemainingTime,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Day $day',
                style: context.textTheme.titleMedium,
              ),
              Text(
                '${currentIndex + 1}/$totalCount 동작',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 16,
                  color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  totalRemainingTime,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── _ExerciseContent ───────────────────────────────────────

class _ExerciseContent extends StatelessWidget {
  final String exercise;
  final Animation<double> timerAnimation;

  const _ExerciseContent({
    required this.exercise,
    required this.timerAnimation,
  });

  String _getExerciseDescription(String exercise) {
    // Placeholder descriptions - will be replaced with expert content
    if (exercise.contains('ST')) {
      return '이 스트레칭은 해당 부위의 근육을 부드럽게 이완시켜줍니다.\n\n'
          '• 통증이 없는 범위에서 천천히 진행하세요\n'
          '• 호흡을 멈추지 말고 자연스럽게 유지하세요\n'
          '• 당김이 느껴지는 지점에서 유지하세요';
    } else if (exercise.contains('EX')) {
      return '이 운동은 약해진 근육을 강화하는 데 도움이 됩니다.\n\n'
          '• 정확한 자세를 유지하며 천천히 진행하세요\n'
          '• 무리하지 않는 범위에서 반복하세요\n'
          '• 움직임의 끝에서 잠시 유지하세요';
    } else if (exercise.contains('Rotation')) {
      return '회전 동작은 관절의 가동범위를 회복하는 데 효과적입니다.\n\n'
          '• 부드럽게, 끝까지 움직여주세요\n'
          '• 통증이 있으면 범위를 줄이세요\n'
          '• 양쪽을 균등하게 진행하세요';
    } else if (exercise.contains('Traction')) {
      return '견인 동작은 관절 사이 공간을 확보해 압박을 줄여줍니다.\n\n'
          '• 강한 힘보다는 지속적인 당김이 중요합니다\n'
          '• 편안한 자세에서 진행하세요';
    }
    return '이 동작을 천천히, 호흡에 맞춰 진행해주세요.\n\n'
        '• 통증이 느껴지면 즉시 멈추세요\n'
        '• 자연스러운 호흡을 유지하세요\n'
        '• 무리하지 않는 것이 가장 중요합니다';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // Exercise name
          Text(
            exercise,
            style: context.headlineMedium,
          ),
          const SizedBox(height: 20),

          // Video placeholder with smooth timer ring
          SoftCard(
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Video placeholder
                  Container(
                    decoration: BoxDecoration(
                      color: context.colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.play_circle_outline,
                        size: 64,
                        color: context.colorScheme.primary.withValues(alpha: 0.5),
                      ),
                    ),
                  ),

                  // Smooth circular timer (no numbers)
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: AnimatedBuilder(
                      animation: timerAnimation,
                      builder: (context, child) {
                        return _SmoothCircularTimer(
                          progress: timerAnimation.value,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Exercise Description Section (NEW)
          SoftCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 18,
                        color: context.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '운동 설명',
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _getExerciseDescription(exercise),
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurface.withValues(alpha: 0.8),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─── _SmoothCircularTimer ───────────────────────────────────

class _SmoothCircularTimer extends StatelessWidget {
  final double progress;

  const _SmoothCircularTimer({
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: context.colorScheme.surface.withValues(alpha: 0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: CircularProgressIndicator(
          value: progress,
          strokeWidth: 3,
          strokeCap: StrokeCap.round,
          backgroundColor: context.colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation<Color>(
            context.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

// ─── _BottomSection ─────────────────────────────────────────

class _BottomSection extends StatelessWidget {
  final String currentExercise;
  final String? nextExercise;
  final bool isLastExercise;
  final VoidCallback? onPrevious;

  const _BottomSection({
    required this.currentExercise,
    required this.nextExercise,
    required this.isLastExercise,
    this.onPrevious,
  });

  String _getExpertTip(String exercise) {
    if (exercise.contains('ST')) {
      return '스트레칭은 통증 없이 당김이 느껴질 정도로 유지하세요';
    } else if (exercise.contains('EX')) {
      return '근력 운동은 정확한 자세가 중요합니다';
    } else if (exercise.contains('Rotation')) {
      return '회전 동작은 천천히, 끝까지 움직여주세요';
    }
    return '무리하지 않는 범위에서 진행해주세요';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: context.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Expert tip (optional, short)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 18,
                color: context.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getExpertTip(currentExercise),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Up Next preview
          Row(
            children: [
              if (onPrevious != null)
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  iconSize: 28,
                  onPressed: onPrevious,
                  color: context.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: context.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isLastExercise ? Icons.flag_outlined : Icons.skip_next,
                        size: 20,
                        color: context.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isLastExercise ? '마지막 동작' : '다음 동작',
                              style: context.textTheme.labelSmall?.copyWith(
                                color: context.colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                            Text(
                              isLastExercise
                                  ? '오늘 루틴 완료!'
                                  : nextExercise ?? '',
                              style: context.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Double-tap hint
          const SizedBox(height: 12),
          Center(
            child: Text(
              '화면을 두 번 탭하면 다음으로 넘어갑니다',
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── _CalmTransitionOverlay ─────────────────────────────────

class _CalmTransitionOverlay extends StatelessWidget {
  final Animation<double> progressAnimation;
  final String? nextExercise;
  final bool isLastExercise;
  final VoidCallback onHold;
  final VoidCallback onSkip;

  const _CalmTransitionOverlay({
    required this.progressAnimation,
    required this.nextExercise,
    required this.isLastExercise,
    required this.onHold,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progressAnimation,
      builder: (context, child) {
        return Container(
          color: context.colorScheme.scrim.withValues(alpha: 0.75),
          child: SafeArea(
            child: Column(
              children: [
                // Subtle progress bar at top
                LinearProgressIndicator(
                  value: progressAnimation.value,
                  minHeight: 3,
                  backgroundColor:
                      context.colorScheme.surface.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    context.colorScheme.primary.withValues(alpha: 0.8),
                  ),
                ),

                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Calm message (no countdown numbers)
                          Text(
                            isLastExercise
                                ? '수고하셨습니다'
                                : '잠시 후 다음 운동으로 넘어갑니다',
                            style: context.textTheme.titleLarge?.copyWith(
                              color: context.colorScheme.onPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),

                          // Next exercise preview
                          if (!isLastExercise && nextExercise != null)
                            Text(
                              nextExercise!,
                              style: context.textTheme.bodyLarge?.copyWith(
                                color: context.colorScheme.onPrimary
                                    .withValues(alpha: 0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),

                          if (isLastExercise)
                            Text(
                              '오늘의 루틴을 완료했습니다',
                              style: context.textTheme.bodyLarge?.copyWith(
                                color: context.colorScheme.onPrimary
                                    .withValues(alpha: 0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),

                          const SizedBox(height: 48),

                          // Hold button (clearly visible)
                          FilledButton.tonal(
                            onPressed: onHold,
                            style: FilledButton.styleFrom(
                              backgroundColor: context.colorScheme.surface,
                              foregroundColor: context.colorScheme.onSurface,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              minimumSize: const Size(200, 52),
                            ),
                            child: Text(
                              '잠시 더 하기',
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Skip button (subtle)
                          TextButton(
                            onPressed: onSkip,
                            child: Text(
                              isLastExercise ? '완료하기' : '바로 넘어가기',
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: context.colorScheme.onPrimary
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
