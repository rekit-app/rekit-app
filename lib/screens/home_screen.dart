import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/storage_keys.dart';
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

  Future<void> _startProgram() async {
    final dx = diagnosisCode;
    if (dx == null || dx.isEmpty) return;

    // ProgramScreen으로 이동 (diagnosisCode, day, stage 전달)
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

    // 돌아왔을 때 데이터 리로드
    _loadData();
  }

  Future<void> _goToPaywall() async {
    final dx = diagnosisCode;
    if (dx == null || dx.isEmpty) return;

    // PaywallScreen으로 이동 (diagnosisCode 전달)
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaywallScreen(diagnosisCode: dx),
      ),
    );

    // 돌아왔을 때 데이터 리로드
    _loadData();
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
      appBar: AppBar(
        title: const Text('Rekit'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stage $stage · Day $day',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              '오늘의 운동',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: routine.length,
                itemBuilder: (ctx, idx) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(child: Text('${idx + 1}')),
                      title: Text(routine[idx]),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startProgram,
                child: const Text('시작하기'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _goToPaywall,
                child: const Text('Stage 2로 가기 (테스트)'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
