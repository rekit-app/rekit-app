import 'package:flutter/material.dart';
import 'program_screen.dart';

class PaywallScreen extends StatelessWidget {
  final String diagnosisCode;

  const PaywallScreen({
    super.key,
    required this.diagnosisCode,
  });

  Future<void> _unlockStage2(BuildContext context) async {
    // Stage 2, Day 1로 ProgramScreen 진입
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProgramScreen(
          diagnosisCode: diagnosisCode,
          day: 1,
          stage: 2,
        ),
      ),
    );

    if (!context.mounted) return;

    // Paywall 닫기
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stage 2 잠금 해제'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.lock_outline,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 32),
            Text(
              'Stage 2: 근력 강화',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Stage 1을 완료하셨습니다!\n더 강력한 근력 강화 프로그램을 시작하세요.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () => _unlockStage2(context),
              child: const Text('Stage 2 시작하기'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('나중에 하기'),
            ),
          ],
        ),
      ),
    );
  }
}
