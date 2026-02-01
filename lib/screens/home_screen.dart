import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/storage_keys.dart';
import '../core/extensions/context_theme.dart';
import '../core/utils/progress_helper.dart';
import '../core/config/stage_config.dart';
import '../features/diagnosis/data/programs.dart';
import 'program_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String diagnosisCode = '';
  int day = 1;
  int stage = 1;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Phase2: Firebase 대비 abstraction point
  Future<SharedPreferences> _prefs() async {
    return SharedPreferences.getInstance();
  }

  Future<void> _loadData() async {
    final prefs = await _prefs();

    setState(() {
      diagnosisCode = prefs.getString(StorageKeys.diagnosisCode) ?? '';
      day = prefs.getInt(StorageKeys.day) ?? 1;
      stage = prefs.getInt(StorageKeys.stage) ?? 1;
      isLoading = false;
    });
  }

  Future<void> _handleContinue() async {
    final enteredStage2 = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const ProgramScreen()),
    );

    if (enteredStage2 == true) {
      _showStage2Dialog();
    }

    await _loadData();
  }

  void _showStage2Dialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('🎉 몸의 움직임이 충분히 회복되었습니다'),
        content: const Text(
          '지금까지는 관절 가동성과 스트레칭 단계였습니다.\n'
          '이제 근력 저하를 개선하는 2단계 운동을 시작할 수 있습니다.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/paywall');
            },
            child: const Text('2단계 운동 시작하기'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('기존 루틴 계속하기 (무료)'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('오늘은 여기까지'),
          ),
        ],
      ),
    );
  }

  // 🔑 stage 판단은 build 밖 메서드로 분리
  Widget _buildBody() {
    if (stage == 1) return _buildFreeHome();
    return _buildPaidHome();
  }

  Widget _buildFreeHome() {
    final maxDays = getStage1Days(diagnosisCode);
    final progress = getStageProgress(day, maxDays);
    // 🔑 program은 여기서 즉시 계산 — state 아님
    final todayProgram = programs[diagnosisCode]?[stage] ?? <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProgressSection(
          stage: stage,
          day: day,
          maxDays: maxDays,
          progress: progress,
        ),
        const SizedBox(height: 24),
        TodayProgramList(program: todayProgram),
      ],
    );
  }

  Widget _buildPaidHome() {
    final todayProgram = programs[diagnosisCode]?[stage] ?? <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [TodayProgramList(program: todayProgram)],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 🔑 program은 _buildBody 내부에서 계산되므로 여기서 참조 불가
    final todayProgram = programs[diagnosisCode]?[stage] ?? <String>[];

    return Scaffold(
      appBar: AppBar(title: const Text('홈')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildBody()),
            if (todayProgram.isNotEmpty) _BottomCTA(onTap: _handleContinue),
          ],
        ),
      ),
    );
  }
}

// ─── ProgressSection ────────────────────────────────────────

class ProgressSection extends StatelessWidget {
  final int stage;
  final int day;
  final int maxDays;
  final double progress;

  const ProgressSection({
    super.key,
    required this.stage,
    required this.day,
    required this.maxDays,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Stage $stage',
              // 🔑 copyWith 제거 — Theme에서 정의
              style: context.textTheme.titleLarge,
            ),
            Text('Day $day / $maxDays', style: context.textTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          // 🔑 valueColor, backgroundColor 제거 — Theme 기본값 사용
          child: LinearProgressIndicator(value: progress, minHeight: 10),
        ),
      ],
    );
  }
}

// ─── TodayProgramList ───────────────────────────────────────

class TodayProgramList extends StatelessWidget {
  final List<String> program;

  const TodayProgramList({super.key, required this.program});

  @override
  Widget build(BuildContext context) {
    if (program.isEmpty) {
      return Text('진행 중인 프로그램이 없습니다.', style: context.textTheme.bodyMedium);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '오늘의 운동',
          // 🔑 copyWith 제거 — Theme에서 정의
          style: context.textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        ...program.map((exercise) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.fitness_center,
                      // 🔑 color 직접 지정 제거 — Icon Theme 기본값 사용
                    ),
                    const SizedBox(width: 12),
                    Text(exercise, style: context.textTheme.bodyMedium),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}

// ─── _BottomCTA ─────────────────────────────────────────────

class _BottomCTA extends StatelessWidget {
  final VoidCallback onTap;

  const _BottomCTA({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        child: Text(
          '계속하기',
          // 🔑 copyWith 제거 — Theme에서 정의
          style: context.textTheme.titleMedium,
        ),
      ),
    );
  }
}
