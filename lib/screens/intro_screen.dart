import 'package:flutter/material.dart';
import 'login_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _totalPages = 3;

  void _onNext() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final isLastPage = _currentPage == _totalPages - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // PageView
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: const [
                  _IntroPage(
                    icon: Icons.search_rounded,
                    title: '진단',
                    subtitle: '통증의 원인을 찾아드립니다',
                    description: '간단한 질문으로 어깨·목·허리 통증의\n정확한 원인을 파악합니다.',
                  ),
                  _IntroPage(
                    icon: Icons.assignment_rounded,
                    title: '처방',
                    subtitle: '맞춤 운동 프로그램',
                    description: '진단 결과에 기반한\n단계별 재활 운동을 제공합니다.',
                  ),
                  _IntroPage(
                    icon: Icons.trending_up_rounded,
                    title: '회복',
                    subtitle: '꾸준한 회복을 함께',
                    description: '매일의 운동 기록을 추적하고\n완전한 회복까지 함께합니다.',
                  ),
                ],
              ),
            ),

            // Bottom section: indicator + button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                children: [
                  // Page indicator
                  _PageDots(
                    currentPage: _currentPage,
                    totalPages: _totalPages,
                  ),
                  const SizedBox(height: 32),

                  // CTA button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _onNext,
                      child: Text(
                        isLastPage ? '시작하기' : '다음',
                        style: text.titleMedium?.copyWith(
                          color: colors.onPrimary,
                          fontWeight: FontWeight.w700,
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
    );
  }
}

// ─── _IntroPage ─────────────────────────────────────────────

class _IntroPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;

  const _IntroPage({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon illustration
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 64,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 48),

          // Title
          Text(
            title,
            style: text.headlineLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Subtitle
          Text(
            subtitle,
            style: text.titleLarge?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            description,
            style: text.bodyLarge?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── _PageDots ──────────────────────────────────────────────

class _PageDots extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const _PageDots({
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) {
        final isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isActive ? colors.primary : colors.outlineVariant,
          ),
        );
      }),
    );
  }
}
