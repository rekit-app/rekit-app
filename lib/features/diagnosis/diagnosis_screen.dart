import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'body_part.dart';
import 'data/shoulder_questions.dart';
import 'data/neck_questions.dart';
import '../../core/storage_keys.dart';
import '../../screens/result_screen.dart';
// import 'data/back_questions.dart';  // 나중에 추가

class DiagnosisScreen extends StatefulWidget {
  final BodyPart bodyPart;

  const DiagnosisScreen({super.key, required this.bodyPart});

  @override
  State<DiagnosisScreen> createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen> {
  String currentQuestion = 'Q01';

  Map<String, Map<String, dynamic>> get questions {
    switch (widget.bodyPart) {
      case BodyPart.shoulder:
        return shoulderQuestions;
      case BodyPart.neck:
        return neckQuestions;
      case BodyPart.back:
        // return backQuestions;  // 나중에 추가
        return {};
    }
  }

  bool _isDiagnosisCode(String code) {
    return code.startsWith('DX_');
  }

  bool _isBodyPartTransition(String code) {
    return code == 'NECK' || code == 'BACK' || code == 'SHOULDER';
  }

  Future<void> _handleAnswer(String next) async {
    if (_isDiagnosisCode(next)) {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(StorageKeys.diagnosisCode, next);
      await prefs.setInt(StorageKeys.day, 1);
      await prefs.setInt(StorageKeys.stage, 1);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ResultScreen()),
      );

      return;
    }

    if (_isBodyPartTransition(next)) {
      BodyPart targetBodyPart;
      if (next == 'NECK') {
        targetBodyPart = BodyPart.neck;
      } else if (next == 'BACK') {
        targetBodyPart = BodyPart.back;
      } else {
        targetBodyPart = BodyPart.shoulder;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DiagnosisScreen(bodyPart: targetBodyPart),
        ),
      );
      return;
    }

    setState(() {
      currentQuestion = next;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('${widget.bodyPart.displayName} 진단')),
        body: Center(child: Text('${widget.bodyPart.displayName} 진단 준비 중입니다.')),
      );
    }

    final questionData = questions[currentQuestion];
    if (questionData == null) {
      return Scaffold(
        appBar: AppBar(title: Text('${widget.bodyPart.displayName} 진단')),
        body: Center(child: Text('질문을 찾을 수 없습니다: $currentQuestion')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('${widget.bodyPart.displayName} 진단')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              questionData['title'],
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(questionData['question'],
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 24),
            ...(questionData['options'] as List).map((option) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _handleAnswer(option['next']),
                    child: Text(option['text']),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
