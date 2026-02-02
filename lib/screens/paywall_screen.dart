import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/extensions/context_theme.dart';
import '../core/config/demo_mode.dart';
import '../core/storage_keys.dart';
import 'program_screen.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  Future<void> _onPurchase() async {
    if (allowDemoPaywallBypass()) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProgramScreen()),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(StorageKeys.stage, 2);
    await prefs.setInt(StorageKeys.day, 1);

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProgramScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('심화 프로그램')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '심화 프로그램 시작',
              style: context.textTheme.titleMedium,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _onPurchase,
                child: Text(
                  '지금 시작하기',
                  style: context.textTheme.titleMedium,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  '나중에',
                  style: context.textTheme.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '본 버전은 기기 내 저장 방식을 사용하며, 앱 삭제 시 진행 데이터가 초기화될 수 있습니다.',
              style: context.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
