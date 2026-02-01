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
      // bypass
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(StorageKeys.stage, 2);
    await prefs.setInt(StorageKeys.day, 1);

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProgramScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('프리미엄')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Stage2는 유료입니다', style: context.textTheme.titleMedium),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _onPurchase,
                child: Text('계속', style: context.textTheme.titleMedium),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('나중에', style: context.textTheme.bodyMedium),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
