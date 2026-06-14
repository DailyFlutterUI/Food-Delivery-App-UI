import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'coin.dart';
import 'savings_theme.dart';

/// A single welcome screen for Money Rain: a slow, premium loop of coins
/// drifting down behind a glowing headline, with one CTA to begin.
class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key, required this.onDone});
  final VoidCallback onDone;

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with TickerProviderStateMixin {
  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8),
  )..repeat();

  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..forward();

  late final List<FallingCoin> _coins =
      List.generate(20, (_) => FallingCoin.random(math.Random(7)));

  @override
  void dispose() {
    _loop.dispose();
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titleIn = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.1, 0.7, curve: Curves.easeOutCubic),
    );
    final bodyIn = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.3, 0.85, curve: Curves.easeOutCubic),
    );
    final ctaIn = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOutBack),
    );

    return Scaffold(
      backgroundColor: S.bg,
      body: Stack(
        children: [
          // Ambient drifting coins (slow, sparse — premium, not busy).
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _loop,
                builder: (_, _) => CustomPaint(
                  painter: _DriftPainter(t: _loop.value, coins: _coins),
                ),
              ),
            ),
          ),
          // Soft accent halo, top.
          Positioned(
            top: -120,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 360,
                height: 360,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [S.accentHalo, S.accent.withAlpha(0)],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  _Hero(loop: _loop, entrance: _entrance),
                  const Spacer(flex: 2),
                  _reveal(
                    titleIn,
                    const Text(
                      'Watch your\nsavings rain in',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: S.fontDisplay,
                        fontSize: 36,
                        height: 1.08,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.6,
                        color: S.ink,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _reveal(
                    bodyIn,
                    const Text(
                      'Every dollar you save falls like golden rain and fills your jar. Hit a milestone, and the sky opens up.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: S.font,
                        fontSize: 15,
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                        color: S.inkSoft,
                      ),
                    ),
                  ),
                  const Spacer(flex: 3),
                  _reveal(ctaIn, _Cta(onTap: widget.onDone)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reveal(Animation<double> a, Widget child) {
    return AnimatedBuilder(
      animation: a,
      builder: (_, child) => Opacity(
        opacity: a.value.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, 22 * (1 - a.value.clamp(0.0, 1.0))),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

/// A big glass coin medallion that bobs and catches the light.
class _Hero extends StatelessWidget {
  const _Hero({required this.loop, required this.entrance});
  final AnimationController loop;
  final AnimationController entrance;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([loop, entrance]),
      builder: (_, _) {
        final tau = loop.value * 2 * math.pi;
        final bob = math.sin(tau) * 10;
        final pop = 0.6 + 0.4 * Curves.easeOutBack.transform(entrance.value);
        return Transform.translate(
          offset: Offset(0, bob),
          child: Transform.scale(
            scale: pop,
            child: SizedBox(
              width: 160,
              height: 160,
              child: CustomPaint(
                painter: _BigCoinPainter(tilt: math.cos(tau) * 0.18 + 0.82),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BigCoinPainter extends CustomPainter {
  _BigCoinPainter({required this.tilt});
  final double tilt;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    paintCoin(canvas, center: c, radius: size.width / 2 - 6, tilt: tilt);
  }

  @override
  bool shouldRepaint(_BigCoinPainter old) => old.tilt != tilt;
}

class _DriftPainter extends CustomPainter {
  _DriftPainter({required this.t, required this.coins});
  final double t;
  final List<FallingCoin> coins;

  @override
  void paint(Canvas canvas, Size size) {
    for (final c in coins) {
      final p = ((t + c.delay) % 1.0);
      final dx = (c.x + c.drift * math.sin(p * 4 + c.wobble)) * size.width;
      final dy = (p * 1.1 - 0.05) * size.height;
      final tilt = math.sin(p * c.spin * math.pi + c.wobble) * 0.5 + 0.5;
      paintCoin(
        canvas,
        center: Offset(dx, dy),
        radius: c.radius * 0.7,
        tilt: tilt,
        opacity: 0.22,
      );
    }
  }

  @override
  bool shouldRepaint(_DriftPainter old) => old.t != t;
}

class _Cta extends StatelessWidget {
  const _Cta({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        height: 58,
        width: double.infinity,
        decoration: BoxDecoration(
          color: S.accent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: S.accentGlow,
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: const Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Start saving',
                style: TextStyle(
                  fontFamily: S.fontDisplay,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
