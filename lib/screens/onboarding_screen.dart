import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/ambient_background.dart';
import '../widgets/glass.dart';
import '../widgets/gradient_button.dart';
import '../widgets/iridescent_orb.dart';

class OnboardingPageData {
  const OnboardingPageData(
    this.eyebrow,
    this.titleTop,
    this.titleAccent,
    this.subtitle,
    this.accent,
  );
  final String eyebrow;
  final String titleTop;
  final String titleAccent;
  final String subtitle;
  final Color accent;
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onFinish});

  final VoidCallback onFinish;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  // QA-only screenshot hooks (default 0 / off).
  static const _qaPage = int.fromEnvironment('OB_PAGE');
  static const _qaEnergy = int.fromEnvironment('OB_ENERGY'); // 0..100

  late final _controller = PageController(initialPage: _qaPage);
  late final AnimationController _burst;
  late int _page = _qaPage;

  static const _pages = [
    OnboardingPageData(
      'INTELLIGENT CAPTURE',
      'AI Smart notes',
      'that summarize',
      'Organize and understand your ideas automatically — the moment you capture them.',
      AppColors.accentBlue,
    ),
    OnboardingPageData(
      'ANY SOURCE',
      'Voice & docs',
      'into clean notes',
      'Record, upload, or paste anything. We structure it into beautiful notes in seconds.',
      AppColors.accentCyan,
    ),
    OnboardingPageData(
      'STUDY SMARTER',
      'Quizzes & chat',
      'from your notes',
      'Auto-generate quizzes and talk to an AI tutor that knows everything you saved.',
      AppColors.accentRose,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _burst = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
  }

  /// Live page position, read straight from the controller during paint.
  /// Falls back to the settled page before the viewport has dimensions.
  double get _livePage {
    if (_controller.hasClients && _controller.position.haveDimensions) {
      return _controller.page ?? _page.toDouble();
    }
    return _page.toDouble();
  }

  void _next() {
    if (_page < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 480),
        curve: Curves.easeOutCubic,
      );
    } else {
      widget.onFinish();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _burst.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _brandRow(),

              // Hero orb — reactive to the swipe. Only this subtree rebuilds
              // per frame (driven by the page controller + burst), so the
              // PageView, text and footer never re-layout mid-scroll.
              SizedBox(
                height: media.size.height * 0.40,
                child: Center(
                  child: RepaintBoundary(
                    child: AnimatedBuilder(
                      animation: Listenable.merge([_controller, _burst]),
                      builder: (context, _) {
                        final page = _livePage;
                        final frac = page - page.floorToDouble();
                        // energy: 0 at rest, peaks at mid-swipe (symmetric).
                        final energy = math.sin(frac * math.pi);
                        // drift: continuous elastic lean, 0 at every page
                        // boundary and at mid-swipe — never snaps sign.
                        final drift = math.sin(frac * 2 * math.pi);
                        return IridescentOrb(
                          size: media.size.width * 0.64,
                          pageValue: page,
                          energy: _qaEnergy > 0 ? _qaEnergy / 100 : energy,
                          drift: _qaEnergy > 0 ? 1 : drift,
                          burst: 1 - _burst.value,
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Paged text.
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (i) {
                    setState(() => _page = i);
                    _burst.forward(from: 0);
                  },
                  itemBuilder: (context, i) => _pageText(context, _pages[i]),
                ),
              ),

              _footer(media),
            ],
          ),
        ),
      ),
    );
  }

  Widget _brandRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          const Text(
            'AI Note 2.0',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Pressable(
            onTap: widget.onFinish,
            child: const Text(
              'Skip',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pageText(BuildContext context, OnboardingPageData p) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Eyebrow with a small colored dot.
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: p.accent,
                  boxShadow: [
                    BoxShadow(
                      color: p.accent.withValues(alpha: 0.7),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                p.eyebrow,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  letterSpacing: 2.2,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.displayLarge,
              children: [
                TextSpan(text: '${p.titleTop}\n'),
                TextSpan(
                  text: p.titleAccent,
                  style: TextStyle(color: p.accent),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(p.subtitle, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _footer(MediaQueryData media) {
    final accent = _pages[_page].accent;
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 18),
      child: Column(
        children: [
          Row(
            children: [
              for (int i = 0; i < _pages.length; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.only(right: 6),
                  width: i == _page ? 30 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: i == _page
                        ? accent
                        : Colors.white.withValues(alpha: 0.2),
                  ),
                ),
              const Spacer(),
              Text(
                '0${_page + 1} / 0${_pages.length}',
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          GradientButton(
            label: _page == _pages.length - 1 ? 'Get Started' : 'Continue',
            onPressed: _next,
          ),
        ],
      ),
    );
  }
}
