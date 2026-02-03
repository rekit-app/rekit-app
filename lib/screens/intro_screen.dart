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
    final text = Theme.of(context).textTheme;
    final isLastPage = _currentPage == _totalPages - 1;

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
                      icon: Icons.tune_rounded,
                      title: '내 몸에 맞춘\n재활 루틴 설계',
                      subtitle: '간단한 상태 체크로\n오늘의 회복 루틴을 추천해드려요',
                    ),
                    _IntroPage(
                      icon: Icons.verified_rounded,
                      title: '현장 기반의\n검증된 데이터',
                      subtitle: '도수치료 환자 6만 건 데이터 기반\n간호사 · 퍼스널 트레이너 · 필라테스 강사 협업',
                      footer: '물리치료사가 직접 설계한 회복 프로그램',
                    ),
                    _IntroPage(
                      icon: Icons.self_improvement_rounded,
                      title: '회복은\n일상이 되어야 하니까',
                      subtitle: '무리하지 않고\n꾸준히 할 수 있는 재활을 만듭니다',
                      footer: 'Made by The Answer',
                      subFooter: '재활 현장의 경험을 바탕으로',
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  children: [
                    _PageDots(
                      currentPage: _currentPage,
                      totalPages: _totalPages,
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _onNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF00D09E),
                          elevation: 0,
                        ),
                        child: Text(
                          isLastPage ? '시작하기' : '다음',
                          style: text.titleMedium?.copyWith(
                            color: const Color(0xFF00D09E),
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
      ),
    );
  }
}

// ─── _IntroPage ─────────────────────────────────────────────

class _IntroPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? footer;
  final String? subFooter;

  const _IntroPage({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.footer,
    this.subFooter,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 56,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 40),

          Text(
            title,
            style: text.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          Text(
            subtitle,
            style: text.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
              fontWeight: FontWeight.w500,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),

          if (footer != null) ...[
            const SizedBox(height: 24),
            Text(
              footer!,
              style: text.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.55),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          if (subFooter != null) ...[
            const SizedBox(height: 4),
            Text(
              subFooter!,
              style: text.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.4),
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
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
            color: isActive
                ? Colors.white
                : Colors.white.withValues(alpha: 0.4),
          ),
        );
      }),
    );
  }
}
