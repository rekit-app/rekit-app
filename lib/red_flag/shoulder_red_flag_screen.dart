import 'package:flutter/material.dart';
import '../features/diagnosis/diagnosis_screen.dart';
import '../features/diagnosis/body_part.dart';
import 'red_flag_screen.dart';

class ShoulderRedFlagScreen extends StatelessWidget {
  const ShoulderRedFlagScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RedFlagScreen(
      bodyPartLabel: '어깨',
      heroIcon: Icons.accessibility_new_rounded,
      warningMessage:
          '아래 항목 중 하나라도 해당된다면\n운동 추천을 중단하고 즉시 병원을 방문하세요.',
      confirmLabel: '해당 사항 없음, 시작하기',
      onConfirm: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const DiagnosisScreen(bodyPart: BodyPart.shoulder),
          ),
        );
      },
      items: const [
        RedFlagItem(
          title: '외상 및 골절 의심',
          description:
              '최근 사고, 추락, 혹은 강한 충격 이후 팔을 아예 움직일 수 없거나 모양이 변형된 경우.',
          icon: Icons.broken_image_rounded,
        ),
        RedFlagItem(
          title: '전신 증상 동반',
          description:
              '어깨 통증과 함께 발열, 오한, 식은땀, 또는 이유 없는 체중 감소가 나타나는 경우.',
          icon: Icons.thermostat_rounded,
        ),
        RedFlagItem(
          title: '심혈관 질환 의심',
          description:
              '왼쪽 어깨 통증과 함께 가슴이 조이는 느낌, 턱이나 등으로 퍼지는 통증, 숨 가쁨이 동반되는 경우.',
          icon: Icons.monitor_heart_rounded,
        ),
        RedFlagItem(
          title: '심각한 신경 마비',
          description: '팔에 힘이 전혀 들어가지 않아 물건을 떨어뜨리거나, 대소변 조절에 문제가 생긴 경우.',
          icon: Icons.flash_on_rounded,
        ),
        RedFlagItem(
          title: '극심한 통증',
          description:
              '밤에 잠을 한숨도 잘 수 없을 정도의 칼로 찌르는 듯한 통증이 갑자기 발생한 경우.',
          icon: Icons.bolt_rounded,
        ),
      ],
    );
  }
}
