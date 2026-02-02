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
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    if (questions.isEmpty) {
      return Scaffold(
        body: Center(
          child: Text('${widget.bodyPart.displayName} 진단 준비 중입니다.'),
        ),
      );
    }

    final questionData = questions[currentQuestion];
    if (questionData == null) {
      return Scaffold(
        body: Center(
          child: Text('질문을 찾을 수 없습니다: $currentQuestion'),
        ),
      );
    }

    final options = questionData['options'] as List;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Close / back button
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 8, top: 8),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const Spacer(flex: 1),

                    // Hero illustration
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.help_outline_rounded,
                        size: 48,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Step title (small label)
                    Text(
                      questionData['title'] as String,
                      style: text.labelLarge?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),

                    // Question text (large, bold)
                    Text(
                      questionData['question'] as String,
                      style: text.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const Spacer(flex: 2),

                    // Answer cards
                    ...options.map((option) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _AnswerCard(
                          label: option['text'] as String,
                          onTap: () => _handleAnswer(option['next'] as String),
                        ),
                      );
                    }),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── _AnswerCard ────────────────────────────────────────────

class _AnswerCard extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _AnswerCard({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: colors.outlineVariant,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: text.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
