import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/storage_keys.dart';
import '../core/config/stage_config.dart';
import '../core/utils/progress_helper.dart';
import '../features/diagnosis/data/programs.dart';
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
  bool _blockingPaywall = false;

  @override
  void initState() {
    super.initState();
    _reloadProgress();
  }

  Future<void> _reloadProgress() async {
    final data = await _getData();
    if (!mounted) return;

    setState(() {
      diagnosisCode = data.$1;
      debugPrint('DX LOADED: $diagnosisCode');
      day = data.$2;
      stage = data.$3;
      isLoading = false;
    });
  }

  Future<(String?, int, int)> _getData() async {
    final prefs = await SharedPreferences.getInstance();
    final dx = prefs.getString(StorageKeys.diagnosisCode);
    final d = prefs.getInt(StorageKeys.day) ?? 1;
    final s = prefs.getInt(StorageKeys.stage) ?? 1;
    return (dx, d, s);
  }

  Future<void> _handleHeroCardTap() async {
    final enteredStage2 = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProgramScreen(),
      ),
    );

    // 데이터 리로드
    await _reloadProgress();

    // Stage2 진입 확인
    if (enteredStage2 == true && !_blockingPaywall) {
      _blockingPaywall = true;
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showPaywallDialog();
      });
    }

    if (enteredStage2 != true) {
      _blockingPaywall = false;
    }
  }

  void _showPaywallDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Stage 2 잠금 해제'),
        content: const Text('더 강력한 근력 강화 프로그램을 시작하세요!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('나중에'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx); // Dialog 닫기
              // PaywallScreen으로 이동
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PaywallScreen()),
              );
            },
            child: const Text('잠금 해제'),
          ),
        ],
      ),
    ).then((_) {
      _blockingPaywall = false;
    });
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
        appBar: AppBar(title: const Text('Rekit')),
        body: const Center(
          child: Text('진단 정보가 없습니다.\n진단을 먼저 완료해주세요.'),
        ),
      );
    }

    final stageMap = programs[dx]!;
    final routine = stageMap[stage];
    if (routine == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Rekit')),
        body: const Center(
          child: Text('해당 스테이지의 프로그램이 없습니다.'),
        ),
      );
    }

    final maxDays =
        stage == 1 ? getStage1Days(dx) : programs[dx]![stage]!.length;

    final progress = getStageProgress(day, maxDays);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Header
              const _GreetingHeader(),
              const SizedBox(height: 24),

              // Today Program Hero Card
              TodayProgramHeroCard(
                programTitle: '어깨 가동성 운동 프로그램',
                stage: stage,
                day: day,
                maxDays: maxDays,
                exerciseCount: routine.length,
                progress: progress,
                onTap: _handleHeroCardTap,
              ),
              const SizedBox(height: 32),

              // Discovery Section
              const _DiscoverySection(),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── _GreetingHeader ────────────────────────────────────────

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '안녕하세요, 찬수님',
                style: text.headlineMedium,
              ),
              const SizedBox(height: 4),
              Text(
                '오늘도 꾸준한 회복을 응원합니다',
                style: text.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.person_outline_rounded,
            color: colors.primary,
          ),
        ),
      ],
    );
  }
}

// ─── TodayProgramHeroCard ───────────────────────────────────

class TodayProgramHeroCard extends StatelessWidget {
  final String programTitle;
  final int stage;
  final int day;
  final int maxDays;
  final int exerciseCount;
  final double progress;
  final VoidCallback onTap;

  const TodayProgramHeroCard({
    super.key,
    required this.programTitle,
    required this.stage,
    required this.day,
    required this.maxDays,
    required this.exerciseCount,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final progressPercent = (progress * 100).toInt();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: colors.shadow,
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: icon + stage badge
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.fitness_center_rounded,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        programTitle,
                        style: text.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Stage $stage · Day $day / $maxDays · $exerciseCount개 운동',
                        style: text.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: colors.outlineVariant,
                valueColor: AlwaysStoppedAnimation(colors.primary),
              ),
            ),

            const SizedBox(height: 8),

            // Progress label
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '$progressPercent% 완료',
                style: text.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // CTA button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onTap,
                child: Text(
                  '오늘 운동 시작하기',
                  style: text.titleMedium?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── _DiscoverySection ──────────────────────────────────────

class _DiscoverySection extends StatelessWidget {
  const _DiscoverySection();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '더 알아보기',
          style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _DiscoveryCard(
                icon: Icons.history_rounded,
                iconColor: colors.tertiary,
                iconBgColor: colors.tertiaryContainer,
                label: '운동 기록',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DiscoveryCard(
                icon: Icons.auto_graph_rounded,
                iconColor: colors.secondary,
                iconBgColor: colors.secondaryContainer,
                label: '회복 통계',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _DiscoveryCard(
                icon: Icons.menu_book_rounded,
                iconColor: colors.primary,
                iconBgColor: colors.primaryContainer,
                label: '재활 가이드',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DiscoveryCard(
                icon: Icons.settings_rounded,
                iconColor: colors.onSurfaceVariant,
                iconBgColor: colors.surfaceContainerHighest,
                label: '설정',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── _DiscoveryCard ─────────────────────────────────────────

class _DiscoveryCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String label;

  const _DiscoveryCard({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 14),
          Text(
            label,
            style: text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
