import 'package:flutter/material.dart';
import '../core/extensions/context_theme.dart';
import '../core/ui/soft_card.dart';
import '../core/utils/storage_helper.dart';
import '../features/diagnosis/data/programs.dart';
import 'intro_screen.dart';
import 'program_screen.dart';
import 'paywall_screen.dart';

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

  void _navigateToPremium() {
    if (stage < 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PaywallScreen()),
      );
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

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1) Header
              _Header(day: day),
              const SizedBox(height: 24),

              // 2) Primary Card — Stretching (FREE)
              _PrimaryStretchCard(
                day: day,
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
  final int day;

  const _Header({required this.day});

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
          '어깨 회복을 위한 맞춤 운동이에요',
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
  final VoidCallback onTap;

  const _PrimaryStretchCard({
    required this.day,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon badge
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
            ),
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
          const SizedBox(height: 20),

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
    );
  }
}

// ─── 3) Secondary Card — Exercise (PREMIUM) ─────────────────

class _SecondaryExerciseCard extends StatelessWidget {
  final VoidCallback onTap;

  const _SecondaryExerciseCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Icon badge (smaller)
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

          // Text (one step down)
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

          // Arrow
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: context.colorScheme.onSurfaceVariant,
          ),
        ],
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
          '이런 운동도 도움이 될 수 있어요',
          style: context.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        const _DiscoveryCard(
          title: '견갑 안정화 스트레치',
          subtitle: '가볍게 따라 해보세요',
        ),
        const SizedBox(height: 10),
        const _DiscoveryCard(
          title: '어깨 후면 이완 루틴',
          subtitle: '여유 있을 때 도움이 돼요',
        ),
      ],
    );
  }
}

class _DiscoveryCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _DiscoveryCard({
    required this.title,
    required this.subtitle,
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
