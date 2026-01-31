import 'package:flutter/material.dart';
import '../features/diagnosis/diagnosis_screen.dart';
import '../features/diagnosis/body_part.dart';

class ShoulderRedFlagScreen extends StatelessWidget {
  const ShoulderRedFlagScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFEE2E2), Color(0xFFFFFFFF)],
            stops: [0.0, 0.3],
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
                      '⚠️ 운동 추천 시작 전 필독',
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
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorScheme.error,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          '아래 항목 중 하나라도 해당된다면\n운동 추천을 중단하고 즉시 병원(정형외과/응급실)을 방문하세요.',
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
                        '1. 외상 및 골절 의심',
                        '최근 사고, 추락, 혹은 강한 충격 이후 팔을 아예 움직일 수 없거나 모양이 변형된 경우.',
                      ),
                      _buildRedFlagItem(
                        context,
                        '2. 전신 증상 동반',
                        '어깨 통증과 함께 발열, 오한, 식은땀, 또는 이유 없는 체중 감소가 나타나는 경우. (감염 또는 종양 의심)',
                      ),
                      _buildRedFlagItem(
                        context,
                        '3. 심혈관 질환 의심',
                        '왼쪽 어깨 통증과 함께 가슴이 조이는 느낌, 턱이나 등으로 퍼지는 통증, 숨 가쁨이 동반되는 경우. (심근경색 신호)',
                      ),
                      _buildRedFlagItem(
                        context,
                        '4. 심각한 신경 마비',
                        '팔에 힘이 전혀 들어가지 않아 물건을 떨어뜨리거나, 대소변 조절에 문제가 생긴 경우.',
                      ),
                      _buildRedFlagItem(
                        context,
                        '5. 극심한 통증',
                        '밤에 잠을 한숨도 잘 수 없을 정도의 칼로 찌르는 듯한 통증이 갑자기 발생한 경우, 심장박동이 느껴질 정도로 욱신욱신 하거나 움직일 수 없을 만큼의 통증이 있는 경우. (석회성 건염 등 급성기)',
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
                                  DiagnosisScreen(bodyPart: BodyPart.shoulder),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          '해당 사항 없음, 시작하기',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
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
            child: const Icon(Icons.warning, color: Colors.white, size: 20),
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
