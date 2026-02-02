import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/extensions/context_theme.dart';
import '../core/storage_keys.dart';
import '../core/config/stage_config.dart';
import '../core/config/demo_mode.dart';
import '../core/utils/storage_helper.dart';
import '../features/diagnosis/data/programs.dart';

class ProgramScreen extends StatefulWidget {
  const ProgramScreen({super.key});

  @override
  State<ProgramScreen> createState() => _ProgramScreenState();
}

class _ProgramScreenState extends State<ProgramScreen> {
  String diagnosisCode = '';
  int day = 1;
  int stage = 1;
  bool isLoading = true;
  bool isCompleted = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await _readProgramState();

    setState(() {
      diagnosisCode = data.$1;
      day = data.$2;
      stage = data.$3;
      isLoading = false;
    });
  }

  Future<(String, int, int)> _readProgramState() async {
    final prefs = await SharedPreferences.getInstance();

    return (
      prefs.getString(StorageKeys.diagnosisCode) ?? '',
      prefs.getInt(StorageKeys.day) ?? 1,
      prefs.getInt(StorageKeys.stage) ?? 1,
    );
  }

  Future<void> _completeDay() async {
    if (diagnosisCode.isEmpty) return;

    final increment = getDemoDayIncrement();
    await advanceDay(increment: increment);

    if (!mounted) return;

    if (stage == 1) {
      final maxDays = getStage1Days(diagnosisCode);
      if (day >= maxDays) {
        Navigator.pop(context, true);
        return;
      }
    }

    Navigator.pop(context);
  }

  Future<void> _onCompleteTap() async {
    setState(() => isCompleted = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    await _completeDay();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final todayProgram = programs[diagnosisCode]?[stage] ?? <String>[];

    return Scaffold(
      appBar: AppBar(title: const Text('오늘의 운동')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: todayProgram.length,
              itemBuilder: (ctx, i) => _ExerciseItem(title: todayProgram[i]),
            ),
          ),
          _BottomSection(isCompleted: isCompleted, onTap: _onCompleteTap),
        ],
      ),
    );
  }
}

// ─── _ExerciseItem ──────────────────────────────────────────

class _ExerciseItem extends StatelessWidget {
  final String title;

  const _ExerciseItem({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.fitness_center),
              const SizedBox(width: 12),
              Text(title, style: context.textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── _BottomSection ─────────────────────────────────────────

class _BottomSection extends StatelessWidget {
  final bool isCompleted;
  final VoidCallback onTap;

  const _BottomSection({required this.isCompleted, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Stack(
        children: [
          AnimatedOpacity(
            opacity: isCompleted ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isCompleted ? null : onTap,
                child: Text('오늘 운동 완료', style: context.textTheme.titleMedium),
              ),
            ),
          ),
          if (isCompleted)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 48),
                  SizedBox(height: 12),
                  Text('오늘 운동 완료!'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
