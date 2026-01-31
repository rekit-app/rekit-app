import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/diagnosis/body_part.dart';
import '../core/storage_keys.dart';
import 'home_screen.dart';

class ResultScreen extends StatelessWidget {
  final BodyPart bodyPart;
  final String diagnosisCode;

  const ResultScreen({
    super.key,
    required this.bodyPart,
    required this.diagnosisCode,
  });

  Future<void> _saveAndNavigate(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(StorageKeys.diagnosisCode, diagnosisCode);
    await prefs.setInt(StorageKeys.day, 1);
    await prefs.setInt(StorageKeys.stage, 1);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('진단 결과')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${bodyPart.displayName} 진단 완료',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              '진단 코드: $diagnosisCode',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _saveAndNavigate(context),
                child: const Text('운동 시작하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
