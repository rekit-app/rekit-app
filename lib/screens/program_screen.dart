import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/storage_keys.dart';
import '../core/config/stage_config.dart';
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

  Future<void> _completeDay() async {
    if (diagnosisCode.isEmpty) return;

    final prefs = await _prefs();
    final maxDays = getStage1Days(diagnosisCode);
    final nextDay = day + 1;
    final enteredStage2 = nextDay > maxDays;

    await prefs.setInt(StorageKeys.day, nextDay);

    if (!mounted) return;

    if (enteredStage2) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      Navigator.pop(context, true);
    } else {
      Navigator.pop(context, false);
    }
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

    final todayProgram = programs[diagnosisCode]![stage]!;

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
              Icon(Icons.fitness_center),
              const SizedBox(width: 12),
              Text(title, style: Theme.of(context).textTheme.bodyMedium),
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
          // 완료 버튼
          AnimatedOpacity(
            opacity: isCompleted ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isCompleted ? null : onTap,
                child: Text(
                  '오늘 운동 완료',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
          ),
          // 완료 피드백
          if (isCompleted)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
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
