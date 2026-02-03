import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/extensions/context_theme.dart';
import '../core/config/stage_config.dart';
import '../core/ui/soft_card.dart';
import '../core/utils/progress_helper.dart';
import '../core/utils/storage_helper.dart';
import '../features/diagnosis/data/programs.dart';
import 'intro_screen.dart';
import 'program_screen.dart';
import 'paywall_screen.dart';

// ─── Motivation copy (derived from day only, no persistence) ─

String _getMotivationText(int day) {
  if (day <= 1) return '첫 걸음을 내딛었어요, 화이팅!';
  if (day <= 3) return '$day일째 꾸준히 하고 있어요 👏';
  if (day <= 5) return '벌써 $day일째! 몸이 달라지고 있어요';
  return '$day일 연속 대단해요, 계속 가볼까요?';
}

// ─── HomeScreen ─────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? diagnosisCode;
  int day = 1;
  int stage = 1;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final data = await loadProgress();
    if (!mounted) return;

    setState(() {
      diagnosisCode = data.diagnosisCode;
      day = data.day;
      stage = data.stage;
      isLoading = false;
    });
  }

  void _navigateToProgram() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProgramScreen()),
    );
  }

  Future<void> _navigateToPremium() async {
    if (stage < 2) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PaywallScreen()),
      );

      // If unlocked successfully, reload progress
      if (result == true && mounted) {
        _loadProgress();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Stage 2가 해제되었습니다! 이제 심화 프로그램을 시작할 수 있습니다.'),
            backgroundColor: Color(0xFF00D09E),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      _navigateToProgram();
    }
  }

  Future<void> _resetAndRestart() async {
    await resetDiagnosis();
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const IntroScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final dx = diagnosisCode;
    if (dx == null || programs[dx] == null) {
      return Scaffold(
        body: Center(
          child: Text(
            '진단 정보가 없습니다.\n진단을 먼저 완료해주세요.',
            style: context.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final maxDays = getStage1Days(dx);
    final progress = getStageProgress(day, maxDays);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1) Header
              _Header(diagnosisCode: dx),
              const SizedBox(height: 24),

              // 2) Primary Card — Stretching (FREE)
              _PrimaryStretchCard(
                day: day,
                progress: progress,
                onTap: _navigateToProgram,
              ),
              const SizedBox(height: 16),

              // 3) Secondary Card — Exercise (PREMIUM)
              _SecondaryExerciseCard(
                onTap: _navigateToPremium,
              ),
              const SizedBox(height: 32),

              // 4) Discovery Section
              const _DiscoverySection(),
              const SizedBox(height: 32),

              // 5) Secondary Action — Reset
              _ResetAction(onTap: _resetAndRestart),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── 1) Header ──────────────────────────────────────────────

class _Header extends StatelessWidget {
  final String? diagnosisCode;

  const _Header({required this.diagnosisCode});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '오늘의 재활 루틴',
          style: context.headlineMedium.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${getBodyPartLabel(diagnosisCode)} 회복을 위한 맞춤 운동이에요',
          style: context.bodyMedium.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ─── 2) Primary Card — Stretching (FREE) ────────────────────

class _PrimaryStretchCard extends StatelessWidget {
  final int day;
  final double progress;
  final VoidCallback onTap;

  const _PrimaryStretchCard({
    required this.day,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progressPercent = (progress * 100).toInt();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.colorScheme.primary.withValues(alpha: 0.08),
            context.colorScheme.primary.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.onSurface.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top: icon + progress ring
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Large semantic icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: context.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.self_improvement_rounded,
                    color: context.colorScheme.primary,
                    size: 28,
                  ),
                ),
                const Spacer(),
                // Circular progress ring
                _ProgressRing(
                  progress: progress,
                  label: '$progressPercent%',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Day label
            Text(
              'DAY $day · 오늘의 스트레칭',
              style: context.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              '몸을 부드럽게 풀어주는 루틴이에요',
              style: context.bodyMedium.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '약 6분 · 통증 없는 범위에서 진행하세요',
              style: context.bodySmall.copyWith(
                color: context.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 12),

            // Motivational micro-copy
            Text(
              _getMotivationText(day),
              style: context.bodySmall.copyWith(
                color: context.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // CTA
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onTap,
                child: const Text('바로 시작하기 →'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── _ProgressRing ──────────────────────────────────────────

class _ProgressRing extends StatelessWidget {
  final double progress;
  final String label;

  const _ProgressRing({
    required this.progress,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 52,
      child: CustomPaint(
        painter: _RingPainter(
          progress: progress,
          trackColor: context.colorScheme.outlineVariant,
          fillColor: context.colorScheme.primary,
        ),
        child: Center(
          child: Text(
            label,
            style: context.bodySmall.copyWith(
              fontWeight: FontWeight.w700,
              color: context.colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color fillColor;

  _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 5) / 2;
    const strokeWidth = 5.0;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Fill
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// ─── 3) Secondary Card — Exercise (PREMIUM) ─────────────────

class _SecondaryExerciseCard extends StatelessWidget {
  final VoidCallback onTap;

  const _SecondaryExerciseCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: context.colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: context.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.fitness_center_rounded,
                color: context.colorScheme.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '운동 루틴으로 더 빠르게 회복해요',
                    style: context.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '근력 · 안정성 중심 프로그램',
                    style: context.bodySmall.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '프리미엄에서 제공돼요',
                    style: context.bodySmall.copyWith(
                      color: context.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: context.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 4) Discovery Section ───────────────────────────────────

class _DiscoverySection extends StatelessWidget {
  const _DiscoverySection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '회복 과정에서 많이 하는 운동이에요',
          style: context.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        const _DiscoveryCard(
          title: '견갑 안정화 스트레치',
          subtitle: '가볍게 따라 해보세요',
          tag: '#가볍게 #회복용',
        ),
        const SizedBox(height: 10),
        const _DiscoveryCard(
          title: '어깨 후면 이완 루틴',
          subtitle: '여유 있을 때 도움이 돼요',
          tag: '#이완 #스트레칭',
        ),
      ],
    );
  }
}

class _DiscoveryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String tag;

  const _DiscoveryCard({
    required this.title,
    required this.subtitle,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: context.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.play_arrow_rounded,
              color: context.colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: context.bodySmall.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tag,
                  style: context.bodySmall.copyWith(
                    color: context.colorScheme.primary.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
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

// ─── 5) Reset Action ────────────────────────────────────────

class _ResetAction extends StatelessWidget {
  final VoidCallback onTap;

  const _ResetAction({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          TextButton(
            onPressed: onTap,
            child: Text(
              '지금 상태에 맞게 다시 추천받기',
              style: context.titleSmall.copyWith(
                color: context.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '간단한 진단으로 운동을 다시 추천해드려요',
            style: context.bodySmall.copyWith(
              color: context.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
