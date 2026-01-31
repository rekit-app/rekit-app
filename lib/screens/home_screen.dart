import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/storage_keys.dart';
import '../features/diagnosis/data/programs.dart';
import 'program_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String diagnosisCode = '';
  List<String> program = [];
  int day = 1;
  int stage = 1;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final dx = prefs.getString(StorageKeys.diagnosisCode) ?? '';
    final d = prefs.getInt(StorageKeys.day) ?? 1;
    final s = prefs.getInt(StorageKeys.stage) ?? 1;

    final todayProgram = programs[dx]?[s] ?? <String>[];

    setState(() {
      diagnosisCode = dx;
      day = d;
      stage = s;
      program = todayProgram;
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
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setInt(StorageKeys.stage, 2);
              await prefs.setInt(StorageKeys.day, 1);

              if (context.mounted) {
                Navigator.pop(context);

                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProgramScreen()),
                );

                await _loadData();
              }
            },
            child: const Text('2단계 운동 시작하기'),
          ),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setInt(StorageKeys.day, 1);

              if (context.mounted) {
                Navigator.pop(context);
                await _loadData();
              }
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('홈')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '오늘의 운동',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Stage $stage / Day $day',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            if (program.isEmpty)
              const Text('진행 중인 프로그램이 없습니다.', style: TextStyle(fontSize: 16))
            else
              ...program.map((exercise) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    '• $exercise',
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              }).toList(),
            const Spacer(),
            if (program.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleContinue,
                  child: const Text('계속하기'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
