import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/storage_keys.dart';
import '../features/diagnosis/data/programs.dart';
import '../core/config/stage_config.dart';

class ProgramScreen extends StatefulWidget {
  const ProgramScreen({super.key});

  @override
  State<ProgramScreen> createState() => _ProgramScreenState();
}

class _ProgramScreenState extends State<ProgramScreen> {
  String diagnosisCode = '';
  int stage = 1;
  List<String> program = [];
  List<bool> checked = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgram();
  }

  Future<void> _loadProgram() async {
    final prefs = await SharedPreferences.getInstance();

    final dx = prefs.getString(StorageKeys.diagnosisCode) ?? '';
    final s = prefs.getInt(StorageKeys.stage) ?? 1;

    final programList = programs[dx]?[s] ?? <String>[];

    setState(() {
      diagnosisCode = dx;
      stage = s;
      program = programList;
      checked = List.generate(programList.length, (_) => false);
      isLoading = false;
    });
  }

  Future<void> _handleComplete() async {
    if (!checked.every((c) => c)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('모든 운동을 완료해주세요')));
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    int day = prefs.getInt(StorageKeys.day) ?? 1;
    int stage = prefs.getInt(StorageKeys.stage) ?? 1;

    day++;

    bool enteredStage2 = false;

    final maxDays = getStage1Days(diagnosisCode);

    if (stage == 1 && day > maxDays) {
      stage = 2;
      day = 1;
      enteredStage2 = true;
    }

    await prefs.setInt(StorageKeys.day, day);
    await prefs.setInt(StorageKeys.stage, stage);

    if (mounted) {
      Navigator.pop(context, enteredStage2);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('운동 프로그램')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '오늘의 운동',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            if (program.isEmpty)
              const Text('운동 프로그램이 없습니다.', style: TextStyle(fontSize: 16))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: program.length,
                  itemBuilder: (context, index) {
                    return CheckboxListTile(
                      title: Text(program[index]),
                      value: checked[index],
                      onChanged: (value) {
                        setState(() {
                          checked[index] = value ?? false;
                        });
                      },
                    );
                  },
                ),
              ),
            if (program.isNotEmpty) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleComplete,
                  child: const Text('완료'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
