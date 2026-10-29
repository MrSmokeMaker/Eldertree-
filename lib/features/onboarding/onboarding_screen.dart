import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:family_tree_app/features/onboarding/onboarding_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPageData> _pages = const [
    _OnboardingPageData(
      title: 'Добро пожаловать в Eldertree',
      description:
          'Сохраняйте живую историю вашего рода, сплетая поколения в интерактивном древе памяти.',
      svgAsset: 'assets/icons/heraldic_tree.svg',
      color: Color(0xFF2D4A3E),
    ),
    _OnboardingPageData(
      title: 'Навигация во времени',
      description:
          'Свободно исследуйте ветви предков, открывайте профили и возвращайтесь в эпохи с помощью временной линзы.',
      svgAsset: 'assets/icons/family_compass.svg',
      color: Color(0xFF385648),
    ),
    _OnboardingPageData(
      title: 'Голосовые капсулы',
      description:
          'Записывайте живые голоса, интонации и рассказы родных — они навсегда останутся звучать в профилях.',
      svgAsset: 'assets/icons/voice_capsule.svg',
      color: Color(0xFF423326),
    ),
    _OnboardingPageData(
      title: 'Ваше родовое наследие',
      description:
          'Начните писать летопись своей семьи прямо сейчас — добавьте себя и первых родственников.',
      svgAsset: 'assets/icons/heritage_shield.svg',
      color: Color(0xFF2D4A3E),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    await ref.read(onboardingProvider.notifier).complete();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F1115) : const Color(0xFFF9F8F6),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              final page = _pages[index];
              return _OnboardingPage(data: page);
            },
          ),
          // Page indicators
          Positioned(
            bottom: 110,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) {
                final isSelected = _currentPage == i;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: isSelected ? 28 : 8,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFD4AF37)
                        : colorScheme.primary.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
          // Buttons
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPage > 0)
                  TextButton(
                    onPressed: () => _pageController.previousPage(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOutCubic,
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor:
                          colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    child: const Text('Назад', style: TextStyle(fontSize: 15)),
                  )
                else
                  const SizedBox(width: 80),
                ElevatedButton(
                  onPressed: _onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D4A3E),
                    foregroundColor: const Color(0xFFF9F8F6),
                    elevation: 3,
                    shadowColor: const Color(0xFF2D4A3E).withValues(alpha: 0.4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 36, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side:
                          const BorderSide(color: Color(0xFFD4AF37), width: 1),
                    ),
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1 ? 'Начать' : 'Далее',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                if (_currentPage < _pages.length - 1)
                  TextButton(
                    onPressed: _finish,
                    style: TextButton.styleFrom(
                      foregroundColor:
                          colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    child: const Text('Пропустить',
                        style: TextStyle(fontSize: 15)),
                  )
                else
                  const SizedBox(width: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPageData {
  final String title;
  final String description;
  final String svgAsset;
  final Color color;

  const _OnboardingPageData({
    required this.title,
    required this.description,
    required this.svgAsset,
    required this.color,
  });
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingPageData data;

  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            data.color.withValues(alpha: isDark ? 0.35 : 0.12),
            isDark ? const Color(0xFF0F1115) : const Color(0xFFF9F8F6),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Medallion with luxury border & SVG
              Container(
                width: 150,
                height: 150,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? const Color(0xFF161A20) : Colors.white,
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.18),
                      blurRadius: 28,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color:
                          Colors.black.withValues(alpha: isDark ? 0.4 : 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: SvgPicture.asset(
                  data.svgAsset,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 44),
              Text(
                data.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                      color: isDark
                          ? const Color(0xFFEDEBE7)
                          : const Color(0xFF1B2A24),
                    ),
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: Text(
                  data.description,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.72),
                        height: 1.55,
                        fontSize: 16,
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
