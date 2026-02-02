import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/extensions/context_theme.dart';
import '../core/storage_keys.dart';
import '../core/config/stage_config.dart';
import '../features/diagnosis/data/programs.dart';
import '../core/ui/soft_card.dart';
import 'program_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
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
    final d = prefs.getInt(StorageKeys.day) ?? 0;
    final s = prefs.getInt(StorageKeys.stage) ?? 1;
    return (dx, d, s);
  }

  Future<void> _handleContinue() async {
    final dx = diagnosisCode;
    if (dx == null || dx.isEmpty) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProgramScreen(
          diagnosisCode: dx,
          day: day,
          stage: stage,
        ),
      ),
    );

    _loadData();
  }

  double _getProgress() {
    final dx = diagnosisCode;
    if (dx == null) return 0.0;
    final maxDays = getStage1Days(dx);
    if (maxDays == 0) return 0.0;
    return (day / maxDays).clamp(0.0, 1.0);
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

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            LinearProgressIndicator(
              value: _getProgress(),
              minHeight: 4,
              backgroundColor: context.colorScheme.surfaceVariant,
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Section
                    const SizedBox(height: 8),
                    Text(
                      '안녕하세요, 찬수님! 👋',
                      style: context.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '오늘은 어깨 가동성을 높여볼까요?',
                      style: context.bodyLarge.copyWith(
                        color: context.colorScheme.onSurface
                            .withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '오늘의 프로그램 · Stage $stage',
                      style: context.bodySmall.copyWith(
                        color: context.colorScheme.onSurface
                            .withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Exercise Cards
                    ...routine.map((exercise) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SoftCard(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.fitness_center,
                                    color: context.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      exercise,
                                      style: context.bodyMedium,
                                    ),
                                  ),
                                  Text(
                                    '30초',
                                    style: context.bodySmall.copyWith(
                                      color: context.colorScheme.onSurface
                                          .withValues(alpha: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom CTA
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '오늘의 예상 운동 시간: 5분',
                    style: context.bodySmall.copyWith(
                      color:
                          context.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _handleContinue,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('오늘의 운동 시작하기'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
