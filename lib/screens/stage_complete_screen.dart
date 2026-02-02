import 'package:flutter/material.dart';

class StageCompleteScreen extends StatelessWidget {
  const StageCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline, size: 80),
              const SizedBox(height: 24),
              Text('1단계 완료!', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Text(
                '이제 근력 회복 단계로 넘어갑니다.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    '다음 단계 시작',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
