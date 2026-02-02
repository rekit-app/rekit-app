import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/extensions/context_theme.dart';
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
  int day = 0;
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
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting Header
                _GreetingHeader(),
                const SizedBox(height: 16),

                // Today Program Hero Card
                TodayProgramHeroCard(
                  programTitle: '어깨 가동성 운동 프로그램',
                  stage: stage,
                  day: day,
                  progress: progress,
                  onTap: _handleHeroCardTap,
                ),
                const SizedBox(height: 32),

                // Future sections...
                // Community, Tips, etc.
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── _GreetingHeader ────────────────────────────────────────

class _GreetingHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '안녕하세요, 찬수님! 👋', // TODO: Phase2 - user profile name
          style: context.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          '오늘도 꾸준한 회복을 응원합니다',
          style: context.bodyLarge.copyWith(
            color: context.colorScheme.onSurface.withValues(alpha: 0.7),
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
  final double progress;
  final VoidCallback onTap;

  const TodayProgramHeroCard({
    super.key,
    required this.programTitle,
    required this.stage,
    required this.day,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Program Title
            Text(
              programTitle,
              style: context.titleMedium,
            ),
            const SizedBox(height: 8),

            // Stage / Day
            Text(
              'Stage $stage · Day $day',
              style: context.bodySmall.copyWith(
                color: context.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),

            // CTA
            Text(
              '탭해서 운동 시작 →',
              style: context.textTheme.labelLarge!.copyWith(
                color: context.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),

            // Progress Bar
            LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: context.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(2),
            ),
          ],
        ),
      ),
    );
  }
}
