import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/storage_keys.dart';
import '../core/config/stage_config.dart';
import '../core/utils/progress_helper.dart';
import '../features/diagnosis/data/programs.dart';
import 'program_screen.dart';
import 'paywall_screen.dart';
import '../features/diagnosis/diagnosis_select_screen.dart';

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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Gradient header area ──
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF00A881), Color(0xFF00D09E)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Greeting Header — white text on gradient
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '안녕하세요, 찬수님',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '오늘도 꾸준한 회복을 응원합니다',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.white
                                            .withValues(alpha: 0.85),
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.person_outline_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Today Program Hero Card — white card on gradient
                      TodayProgramHeroCard(
                        programTitle: '어깨 가동성 운동 프로그램',
                        stage: stage,
                        day: day,
                        maxDays: maxDays,
                        exerciseCount: routine.length,
                        progress: progress,
                        onTap: _handleHeroCardTap,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── White content area ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Promo Banner
                  _PromoBanner(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DiagnosisSelectScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 28),

                  // Workout Routines
                  const _WorkoutRoutinesSection(),
                ],
              ),
            ),
          ],
        ),
      ),
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
    final text = Theme.of(context).textTheme;
    final progressPercent = (progress * 100).toInt();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
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
                    color: const Color(0xFFD4F5EC),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.fitness_center_rounded,
                    color: Color(0xFF00D09E),
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
                          color: const Color(0xFF2D3142),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Stage $stage · Day $day / $maxDays · $exerciseCount개 운동',
                        style: text.bodySmall?.copyWith(
                          color: const Color(0xFF6E7787),
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
                backgroundColor: const Color(0xFFE2E8E5),
                valueColor:
                    const AlwaysStoppedAnimation(Color(0xFF00D09E)),
              ),
            ),

            const SizedBox(height: 8),

            // Progress label
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '$progressPercent% 완료',
                style: text.labelSmall?.copyWith(
                  color: const Color(0xFF6E7787),
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
                    color: Colors.white,
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

// ─── _PromoBanner ───────────────────────────────────────────

class _PromoBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _PromoBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF00D09E).withValues(alpha: 0.1),
              const Color(0xFF00A881).withValues(alpha: 0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFF00D09E).withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF00D09E).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.directions_run_rounded,
                color: Color(0xFF00D09E),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            // Text
            Expanded(
              child: Text(
                '나에게 맞는 운동 추천 받으러 가기',
                style: text.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2D3142),
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Color(0xFF00D09E),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── _WorkoutRoutinesSection ────────────────────────────────

class _WorkoutRoutinesSection extends StatelessWidget {
  const _WorkoutRoutinesSection();

  static const _routines = [
    _RoutineData(
      title: '물리치료사가 추천하는\n허리통증 예방 루틴',
      difficulty: '초급',
      duration: '15분',
      icon: Icons.airline_seat_recline_normal_rounded,
    ),
    _RoutineData(
      title: '집에서 하는\n필라테스 인기 동작 5가지',
      difficulty: '중급',
      duration: '20분',
      icon: Icons.self_improvement_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '추천 운동 루틴',
          style: text.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2D3142),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _routines.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final r = _routines[index];
              return _RoutineCard(
                title: r.title,
                difficulty: r.difficulty,
                duration: r.duration,
                icon: r.icon,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RoutineData {
  final String title;
  final String difficulty;
  final String duration;
  final IconData icon;

  const _RoutineData({
    required this.title,
    required this.difficulty,
    required this.duration,
    required this.icon,
  });
}

class _RoutineCard extends StatelessWidget {
  final String title;
  final String difficulty;
  final String duration;
  final IconData icon;

  const _RoutineCard({
    required this.title,
    required this.difficulty,
    required this.duration,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
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
              color: const Color(0xFFD4F5EC),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF00D09E), size: 22),
          ),
          const Spacer(),
          Text(
            title,
            style: text.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2D3142),
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            '$difficulty · $duration',
            style: text.bodySmall?.copyWith(
              color: const Color(0xFF6E7787),
            ),
          ),
        ],
      ),
    );
  }
}

