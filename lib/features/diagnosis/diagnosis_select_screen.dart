import 'package:flutter/material.dart';

import 'package:rekit/red_flag/shoulder_red_flag_screen.dart';
import 'package:rekit/red_flag/back_red_flag_screen.dart';
import 'package:rekit/red_flag/neck_red_flag_screen.dart';

class DiagnosisSelectScreen extends StatefulWidget {
  const DiagnosisSelectScreen({super.key});

  @override
  State<DiagnosisSelectScreen> createState() => _DiagnosisSelectScreenState();
}

class _DiagnosisSelectScreenState extends State<DiagnosisSelectScreen> {
  int? _selectedIndex;

  static const _bodyParts = [
    _BodyPartOption(
      icon: Icons.accessibility_new_rounded,
      label: '어깨 통증',
      description: '어깨 관절·회전근개·오십견',
    ),
    _BodyPartOption(
      icon: Icons.person_rounded,
      label: '목 통증',
      description: '경추·거북목·두통',
    ),
    _BodyPartOption(
      icon: Icons.airline_seat_recline_normal_rounded,
      label: '허리 통증',
      description: '요추·디스크·자세 교정',
    ),
  ];

  void _onConfirm() {
    if (_selectedIndex == null) return;

    const screens = [
      ShoulderRedFlagScreen(),
      NeckRedFlagScreen(),
      BackRedFlagScreen(),
    ];

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screens[_selectedIndex!]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF00D09E), Color(0xFF00A881)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Visual header area
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Column(
                  children: [
                    // Hero illustration — white on gradient
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.health_and_safety_rounded,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title — white on gradient
                    Text(
                      '어디가 불편하신가요?',
                      style: text.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    // Subtitle — white on gradient
                    Text(
                      '맞춤 재활을 위해 통증 부위를 알려주세요.',
                      style: text.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Selection cards
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      ...List.generate(_bodyParts.length, (index) {
                        final part = _bodyParts[index];
                        final isSelected = _selectedIndex == index;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _SelectionCard(
                            icon: part.icon,
                            label: part.label,
                            description: part.description,
                            isSelected: isSelected,
                            onTap: () {
                              setState(() {
                                _selectedIndex = index;
                              });
                            },
                          ),
                        );
                      }),

                      const Spacer(),

                      // CTA button — white on gradient
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              _selectedIndex != null ? _onConfirm : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF00D09E),
                            disabledBackgroundColor:
                                Colors.white.withValues(alpha: 0.4),
                            disabledForegroundColor:
                                Colors.white.withValues(alpha: 0.6),
                            elevation: 0,
                          ),
                          child: Text(
                            '다음',
                            style: text.titleMedium?.copyWith(
                              color: _selectedIndex != null
                                  ? const Color(0xFF00D09E)
                                  : Colors.white.withValues(alpha: 0.6),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── _BodyPartOption (data class) ───────────────────────────

class _BodyPartOption {
  final IconData icon;
  final String label;
  final String description;

  const _BodyPartOption({
    required this.icon,
    required this.label,
    required this.description,
  });
}

// ─── _SelectionCard ─────────────────────────────────────────

class _SelectionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectionCard({
    required this.icon,
    required this.label,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF00D09E)
                : Colors.transparent,
            width: isSelected ? 2.5 : 0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: isSelected ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon circle
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isSelected
                    ? colors.primary
                    : colors.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: 26,
                color: isSelected
                    ? colors.onPrimary
                    : colors.primary,
              ),
            ),
            const SizedBox(width: 16),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: text.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // Check indicator
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isSelected ? 1.0 : 0.0,
              child: Icon(
                Icons.check_circle_rounded,
                color: colors.primary,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
