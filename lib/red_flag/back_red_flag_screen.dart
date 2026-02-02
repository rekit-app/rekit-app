import 'package:flutter/material.dart';
import '../features/diagnosis/diagnosis_screen.dart';
import '../features/diagnosis/body_part.dart';
import 'red_flag_screen.dart';

class BackRedFlagScreen extends StatelessWidget {
  const BackRedFlagScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RedFlagScreen(
      bodyPartLabel: '허리',
      heroIcon: Icons.airline_seat_recline_normal_rounded,
      warningMessage:
          '아래 항목 중 하나라도 해당된다면\n즉시 응급실이나 정형외과를 방문하세요.',
      confirmLabel: '해당 사항 없음, 진단 시작',
      onConfirm: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const DiagnosisScreen(bodyPart: BodyPart.back),
          ),
        );
      },
      items: const [
        RedFlagItem(
          title: '외상 및 골절',
          description: '최근 낙상, 교통사고 등 허리에 강한 충격이 있은 후 통증이 시작된 경우.',
          icon: Icons.broken_image_rounded,
        ),
        RedFlagItem(
          title: '마미증후군 의심',
          description:
              '다리에 힘이 없고, 대소변 조절이 어렵거나, 안장 부위(엉덩이와 항문 주변)의 감각이 없는 경우.',
          icon: Icons.warning_rounded,
        ),
        RedFlagItem(
          title: '심각한 신경 마비',
          description: '발목이나 발가락을 움직일 수 없거나, 한쪽 다리가 완전히 마비된 느낌.',
          icon: Icons.flash_on_rounded,
        ),
        RedFlagItem(
          title: '전신 징후',
          description:
              '설명되지 않는 체중 감소, 발열, 오한, 야간 통증 악화, 또는 암 병력이 있는 경우.',
          icon: Icons.thermostat_rounded,
        ),
        RedFlagItem(
          title: '감염 의심',
          description: '최근 척추 시술이나 주사를 받았고, 발열과 함께 허리 통증이 심해지는 경우.',
          icon: Icons.coronavirus_rounded,
        ),
      ],
    );
  }
}
