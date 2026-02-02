import 'package:flutter/material.dart';
import '../features/diagnosis/diagnosis_screen.dart';
import '../features/diagnosis/body_part.dart';

class BackRedFlagScreen extends StatelessWidget {
  const BackRedFlagScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colorScheme.errorContainer, colorScheme.surface],
            stops: const [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      color: colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '🚨 허리 진단 전 필독',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorScheme.error,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          '잠깐! 아래 항목 중 하나라도 해당된다면\n즉시 응급실이나 정형외과를 방문하세요.',
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.error,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildRedFlagItem(
                        context,
                        '1. 외상 및 골절',
                        '최근 낙상, 교통사고 등 허리에 강한 충격이 있은 후 통증이 시작된 경우.',
                      ),
                      _buildRedFlagItem(
                        context,
                        '2. 마미증후군 의심',
                        '다리에 힘이 없고, 대소변 조절이 어렵거나, 안장 부위(엉덩이와 항문 주변)의 감각이 없는 경우.',
                      ),
                      _buildRedFlagItem(
                        context,
                        '3. 심각한 신경 마비',
                        '발목이나 발가락을 움직일 수 없거나, 한쪽 다리가 완전히 마비된 느낌.',
                      ),
                      _buildRedFlagItem(
                        context,
                        '4. 전신 징후',
                        '설명되지 않는 체중 감소, 발열, 오한, 야간 통증 악화, 또는 암 병력이 있는 경우.',
                      ),
                      _buildRedFlagItem(
                        context,
                        '5. 감염 의심',
                        '최근 척추 시술이나 주사를 받았고, 발열과 함께 허리 통증이 심해지는 경우.',
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const DiagnosisScreen(bodyPart: BodyPart.back),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          '해당 사항 없음, 진단 시작',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.error,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(
                            color: colorScheme.error,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          '해당 사항 있음, 병원 방문',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.error,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRedFlagItem(
    BuildContext context,
    String title,
    String description,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.error,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.warning, color: colorScheme.onError, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
