import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/extensions/context_theme.dart';
import '../core/storage_keys.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  Future<void> _unlockStage2(BuildContext context) async {
    // 1. Show processing state
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      ),
    );

    // 2. Simulate network delay (2.0s)
    await Future.delayed(const Duration(seconds: 2));

    if (!context.mounted) return;

    // 3. Save Data (Unlock Stage 2)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(StorageKeys.stage, 2);
    await prefs.setInt(StorageKeys.day, 1);

    if (!context.mounted) return;

    // 4. Pop Loading Dialog
    Navigator.of(context).pop(); // pop dialog

    // 5. Return success to previous screen
    Navigator.of(context).pop(true); // pop Paywall with success
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

                  // Primary CTA - Premium Gold Button
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _unlockStage2(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.workspace_premium_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '심화 프로그램 시작하기',
                                style: context.titleMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
