import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/extensions/context_theme.dart';
import '../core/utils/progress_helper.dart';
import '../core/config/stage_config.dart';
import '../features/diagnosis/data/programs.dart';
import '../core/utils/storage_helper.dart';
import '../core/storage_keys.dart';
import '../core/ui/soft_card.dart';
import '../core/theme/color_scheme.dart';
import 'program_screen.dart';
import 'stage_complete_screen.dart';
import 'intro_screen.dart';

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

  Future<void> _loadData() async {
    try {
      final data = await _readHomeState();

      setState(() {
        diagnosisCode = data.$1;
        day = data.$2;
        stage = data.$3;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Home load error: $e');
      setState(() => isLoading = false);
    }
  }

  Future<(String, int, int)> _readHomeState() async {
    final prefs = await SharedPreferences.getInstance();

    return (
      prefs.getString(StorageKeys.diagnosisCode) ?? '',
      prefs.getInt(StorageKeys.day) ?? 1,
      prefs.getInt(StorageKeys.stage) ?? 1,
    );
  }

  Future<void> _handleContinue() async {
    final enteredStage2 = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const ProgramScreen()),
    );

    if (!mounted) return;

    if (enteredStage2 == true) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const StageCompleteScreen()),
      );
    }

    if (!mounted) return;
    await _loadData();
  }

  Widget _buildBody() {
    if (stage == 1) return _buildFreeHome();
    return _buildPaidHome();
  }

  Widget _buildFreeHome() {
    final maxDays = getStage1Days(diagnosisCode);
    final progress = getStageProgress(day, maxDays);
    final todayProgram = programs[diagnosisCode]?[stage] ?? <String>[];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _HeroSection(),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SoftCard(
                  child: ProgressSection(
                    stage: stage,
                    day: day,
                    maxDays: maxDays,
                    progress: progress,
                  ),
                ),
                const SizedBox(height: 24),
                const _ActionGrid(),
                const SizedBox(height: 24),
                TodayProgramList(program: todayProgram),
                const SizedBox(height: 24),
                if (todayProgram.isNotEmpty) _BottomCTA(onTap: _handleContinue),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaidHome() {
    final todayProgram = programs[diagnosisCode]?[stage] ?? <String>[];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _HeroSection(),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SoftCard(
                  child: Text('Day $day', style: context.textTheme.titleLarge),
                ),
                const SizedBox(height: 24),
                const _ActionGrid(),
                const SizedBox(height: 24),
                TodayProgramList(program: todayProgram),
                const SizedBox(height: 24),
                if (todayProgram.isNotEmpty) _BottomCTA(onTap: _handleContinue),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (diagnosisCode.isEmpty || programs[diagnosisCode] == null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '프로그램 정보를 불러올 수 없습니다.\n다시 진단해주세요.',
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const IntroScreen()),
                    );
                  },
                  child: Text(
                    '처음으로 돌아가기',
                    style: context.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('홈'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt),
            onPressed: () async {
              await resetDiagnosis();
              if (context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const IntroScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }
}

// ─── _HeroSection ───────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              mintPrimary.withValues(alpha: 0.05),
              surfaceSoft,
            ],
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rekit',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '오늘의 회복 상태',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── _ActionGrid ────────────────────────────────────────────

class _ActionGrid extends StatelessWidget {
  const _ActionGrid();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SoftCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(
                  Icons.fitness_center,
                  size: 32,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                const SizedBox(height: 8),
                Text(
                  '오늘의 운동',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SoftCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(
                  Icons.history,
                  size: 32,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                const SizedBox(height: 8),
                Text(
                  '운동 기록',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SoftCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(
                  Icons.list,
                  size: 32,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                const SizedBox(height: 8),
                Text(
                  '내 루틴',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ],
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
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              'Day $day / $maxDays',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
          ),
        ),
      ],
    );
  }
}

// ─── TodayProgramList ───────────────────────────────────────

class TodayProgramList extends StatelessWidget {
  final List<String> program;

  const TodayProgramList({
    super.key,
    required this.program,
  });

  @override
  Widget build(BuildContext context) {
    if (program.isEmpty) {
      return Text(
        '진행 중인 프로그램이 없습니다.',
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '오늘의 운동',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        ...program.map((exercise) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SoftCard(
              child: Row(
                children: [
                  Icon(
                    Icons.fitness_center,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    exercise,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ─── _BottomCTA ─────────────────────────────────────────────

class _BottomCTA extends StatelessWidget {
  final VoidCallback onTap;

  const _BottomCTA({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        child: Text(
          '맞춤 운동 시작하기',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
