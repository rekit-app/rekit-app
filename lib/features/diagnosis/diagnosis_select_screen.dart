import 'package:flutter/material.dart';

import 'package:rekit/red_flag/shoulder_red_flag_screen.dart';
import 'package:rekit/red_flag/back_red_flag_screen.dart';
import 'package:rekit/red_flag/neck_red_flag_screen.dart';

class DiagnosisSelectScreen extends StatelessWidget {
  const DiagnosisSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('어디가 불편하신가요?')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ShoulderRedFlagScreen(),
                      ),
                    );
                  },
                  child: const Text('어깨 통증'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NeckRedFlagScreen(),
                      ),
                    );
                  },
                  child: const Text('목 통증'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BackRedFlagScreen(),
                      ),
                    );
                  },
                  child: const Text('허리 통증'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
