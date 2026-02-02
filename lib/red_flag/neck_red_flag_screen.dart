import 'package:flutter/material.dart';
import '../features/diagnosis/diagnosis_screen.dart';
import '../features/diagnosis/body_part.dart';
import 'red_flag_screen.dart';

class NeckRedFlagScreen extends StatelessWidget {
  const NeckRedFlagScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RedFlagScreen(
      bodyPartLabel: '목',
      heroIcon: Icons.person_rounded,
      warningMessage:
          '아래 항목 중 하나라도 해당된다면\n즉시 응급실이나 정형외과/신경외과를 방문하세요.',
      confirmLabel: '해당 사항 없음, 진단 시작',
      onConfirm: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const DiagnosisScreen(bodyPart: BodyPart.neck),
          ),
        );
      },
      items: const [
        RedFlagItem(
          title: '외상 및 손상',
          description: '최근 낙상, 교통사고 등 목에 강한 충격이 있은 후 통증이 시작된 경우.',
          icon: Icons.broken_image_rounded,
        ),
        RedFlagItem(
          title: '척수 압박 증상',
          description:
              '걷는 게 휘청거리거나, 젓가락질 등 미세한 손동작이 갑자기 어려워진 경우.',
          icon: Icons.warning_rounded,
        ),
        RedFlagItem(
          title: '심각한 신경 마비',
          description: '팔이나 손에 힘이 들어가지 않아 물건을 계속 놓치는 경우.',
          icon: Icons.flash_on_rounded,
        ),
        RedFlagItem(
          title: '전신 징후',
          description: '설명되지 않는 체중 감소, 발열, 오한, 또는 야간에 극심해지는 통증.',
          icon: Icons.thermostat_rounded,
        ),
        RedFlagItem(
          title: '뇌신경 증상',
          description: '극심한 두통, 어지럼증, 복시(물체가 두 개로 보임), 갑작스러운 발음 어눌함.',
          icon: Icons.psychology_rounded,
        ),
      ],
    );
  }
}
