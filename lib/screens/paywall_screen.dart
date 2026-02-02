import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/extensions/context_theme.dart';
import '../core/storage_keys.dart';
import 'program_screen.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  Future<void> _unlockStage2(BuildContext context) async {
    if (!Navigator.of(context).canPop()) return;

    final prefs = await SharedPreferences.getInstance();

    // Stage2 Day1 설정
    await prefs.setInt(StorageKeys.stage, 2);
    await prefs.setInt(StorageKeys.day, 1);

    if (!context.mounted) return;

    // ProgramScreen으로 이동 (push - Home stack 유지)
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProgramScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Main Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),

                  // Lock Icon
                  Icon(
                    Icons.lock_outline,
                    size: 80,
                    color: context.colorScheme.primary.withValues(alpha: 0.6),
                  ),
                  const SizedBox(height: 32),

                  // Title
                  Text(
                    'Stage 2: 근력 강화',
                    style: context.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    'Stage 1을 완료하셨습니다!\n더 강력한 근력 강화 프로그램을 시작하세요.',
                    style: context.bodyLarge.copyWith(
                      color:
                          context.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Primary CTA
                  ElevatedButton(
                    onPressed: () => _unlockStage2(context),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('심화 프로그램 시작하기'),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Secondary CTA
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('나중에'),
                  ),

                  const Spacer(),

                  // Data Warning
                  Text(
                    '본 버전은 기기 내 저장 방식을 사용하며 앱 삭제 시 진행 데이터가 초기화될 수 있습니다.',
                    style: context.bodySmall.copyWith(
                      color:
                          context.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Close Button (fixed position)
            Positioned(
              top: 0,
              left: 0,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
