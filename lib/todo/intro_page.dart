import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'todo_theme.dart';

/// A 3-page intro the user swipes through on first launch.
///
/// Cute + clean: a soft pink canvas, chunky rounded type, and glossy 3D emoji
/// (Microsoft Fluent Emoji, MIT) as the heroes. The charm is in the motion —
/// heroes bob and tilt in 3D with the swipe, little emoji drift up the
/// background, the page you leave shrinks/tilts/fades while the next pops in,
/// and the final page throws a confetti burst. Calls [onDone] when finished.
class IntroPage extends StatefulWidget {
  const IntroPage({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> with TickerProviderStateMixin {
  final _controller = PageController();

  // Slow ambient loop (bob, float, sway, halo pulse).
  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat();

  // Fires when a page settles — pop + staggered text + per-page burst.
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 850),
  );

  int _page = 0;
  double _pos = 0;

  static const _pages = <_IntroData>[
    _IntroData(
      hero: 'notepad',
      floaters: ['sunflower', 'sparkles', 'heart'],
      title: 'A cozy spot\nfor your tasks',
      body:
          'Welcome to Little Tasks — a calm little place to jot down what matters and keep your day in order.',
    ),
    _IntroData(
      hero: 'check',
      floaters: ['sparkles', 'heart', 'star'],
      title: 'Tick it off,\nfeel the spark',
      body:
          'Tap to complete a task and enjoy a tiny burst of delight every single time. Done has never felt this good.',
    ),
    _IntroData(
      hero: 'fire',
      floaters: ['star', 'popper', 'heart'],
      title: 'Keep your\nstreak alive',
      body:
          'Show up each day and watch your streak grow. Small steps, big momentum. You’ve totally got this 💪',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() => _pos = _controller.page ?? 0));
    _entrance.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _loop.dispose();
    _entrance.dispose();
    super.dispose();
  }

  bool get _isLast => _page == _pages.length - 1;

  void _next() {
    HapticFeedback.lightImpact();
    if (_isLast) {
      widget.onDone();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 480),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _skip() {
    HapticFeedback.selectionClick();
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: T.bg,
      body: Stack(
        children: [
          _DriftingBlob(pos: _pos, loop: _loop),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: AnimatedOpacity(
                    opacity: _isLast ? 0 : 1,
                    duration: const Duration(milliseconds: 250),
                    child: TextButton(
                      onPressed: _isLast ? null : _skip,
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          fontFamily: T.font,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: T.inkSoft,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    onPageChanged: (i) {
                      HapticFeedback.lightImpact();
                      setState(() => _page = i);
                      _entrance.forward(from: 0);
                    },
                    itemCount: _pages.length,
                    itemBuilder: (_, i) => _IntroPanel(
                      data: _pages[i],
                      loop: _loop,
                      entrance: _entrance,
                      delta: i - _pos,
                      isActive: i == _page,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _Dots(count: _pages.length, pos: _pos),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: _CtaButton(isLast: _isLast, onTap: _next),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Page model
// ---------------------------------------------------------------------------

class _IntroData {
  const _IntroData({
    required this.hero,
    required this.floaters,
    required this.title,
    required this.body,
  });

  final String hero; // 3D emoji asset name
  final List<String> floaters; // small 3D emoji that orbit the hero
  final String title;
  final String body;
}

// ---------------------------------------------------------------------------
// A single page. The whole panel scales/tilts/fades by distance from centre;
// the hero + text reveal with a staggered pop on arrival.
// ---------------------------------------------------------------------------

class _IntroPanel extends StatelessWidget {
  const _IntroPanel({
    required this.data,
    required this.loop,
    required this.entrance,
    required this.delta,
    required this.isActive,
  });

  final _IntroData data;
  final AnimationController loop;
  final AnimationController entrance;
  final double delta;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final local = delta.abs().clamp(0.0, 1.0);
    final eased = Curves.easeOutCubic.transform(1 - local);
    final opacity = (1 - local * 1.35).clamp(0.0, 1.0);
    final scale = 0.80 + 0.20 * eased;
    final tilt = delta * 0.12;

    return Opacity(
      opacity: opacity,
      child: Transform.scale(
        scale: scale,
        child: Transform.rotate(
          angle: tilt,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                Transform.translate(
                  offset: Offset(-delta * 80, 0),
                  child: _HeroStage(
                    data: data,
                    loop: loop,
                    entrance: entrance,
                    delta: delta,
                    isActive: isActive,
                  ),
                ),
                const Spacer(flex: 2),
                Transform.translate(
                  offset: Offset(-delta * 38, 0),
                  child: _RevealText(
                    entrance: entrance,
                    isActive: isActive,
                    title: data.title,
                    body: data.body,
                  ),
                ),
                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The hero zone: glossy 3D emoji that bobs + tilts in 3D, a soft halo, orbiting
/// mini emoji, and a sparkle/confetti burst when the page arrives.
class _HeroStage extends StatelessWidget {
  const _HeroStage({
    required this.data,
    required this.loop,
    required this.entrance,
    required this.delta,
    required this.isActive,
  });

  final _IntroData data;
  final AnimationController loop;
  final AnimationController entrance;
  final double delta;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 260,
      child: AnimatedBuilder(
        animation: Listenable.merge([loop, entrance]),
        builder: (context, _) {
          final tau = loop.value * 2 * math.pi;
          final bob = math.sin(tau) * 9;
          final pop = isActive
              ? 0.55 + 0.45 * Curves.easeOutBack.transform(entrance.value)
              : 1.0;
          final ev = isActive ? entrance.value : 1.0;

          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              _Halo(t: loop.value),
              // Orbiting mini emoji.
              ..._orbiters(tau),
              // Burst of little hearts/stars right after arrival.
              ..._burst(ev),
              // The hero, bobbing + tilting in 3D with the swipe.
              Transform.translate(
                offset: Offset(0, bob),
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.0015) // perspective
                    ..rotateY(delta * 0.6 + math.sin(tau) * 0.05)
                    ..rotateX(-math.cos(tau) * 0.05),
                  child: Transform.scale(
                    scale: pop,
                    child: _Emoji(data.hero, size: 150, shadow: true),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _orbiters(double tau) {
    final f = data.floaters;
    return List.generate(f.length, (i) {
      final phase = tau + i * 2 * math.pi / f.length;
      final radius = 96.0 + math.sin(tau + i) * 6;
      final angle = i * 2 * math.pi / f.length - math.pi / 2;
      return Transform.translate(
        offset: Offset(
          math.cos(angle) * radius,
          math.sin(angle) * radius * 0.78 + math.sin(phase) * 6,
        ),
        child: _Emoji(f[i], size: 38 + (i.isEven ? 6 : 0)),
      );
    });
  }

  /// Little emoji bursting outward as the page lands.
  List<Widget> _burst(double ev) {
    final b = ((ev - 0.15) / 0.55).clamp(0.0, 1.0);
    if (b == 0 || b == 1) return const [];
    final fade = 1 - b;
    const pieces = ['heart', 'star', 'sparkles'];
    return List.generate(8, (i) {
      final a = i / 8 * 2 * math.pi;
      final r = 60 + b * 80;
      return Transform.translate(
        offset: Offset(math.cos(a) * r, math.sin(a) * r),
        child: Opacity(
          opacity: fade,
          child: _Emoji(pieces[i % pieces.length], size: 22 + fade * 8),
        ),
      );
    });
  }
}

/// Glossy 3D emoji image with an optional soft contact shadow.
class _Emoji extends StatelessWidget {
  const _Emoji(this.name, {required this.size, this.shadow = false});

  final String name;
  final double size;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final img = Image.asset(
      T.emoji(name),
      width: size,
      height: size,
      filterQuality: FilterQuality.high,
    );
    if (!shadow) return img;
    return Stack(
      alignment: Alignment.center,
      children: [
        // Soft blob shadow under the hero for grounding.
        Positioned(
          bottom: size * 0.04,
          child: Container(
            width: size * 0.6,
            height: size * 0.16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: T.accentDeep.withAlpha(51),
                  blurRadius: 26,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ),
        img,
      ],
    );
  }
}

/// Title + body that slide up and fade in, staggered, when the page lands.
class _RevealText extends StatelessWidget {
  const _RevealText({
    required this.entrance,
    required this.isActive,
    required this.title,
    required this.body,
  });

  final AnimationController entrance;
  final bool isActive;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    Widget staggered(double start, double end, Widget child) {
      return AnimatedBuilder(
        animation: entrance,
        builder: (_, child) {
          final v = isActive
              ? Curves.easeOutCubic.transform(
                  ((entrance.value - start) / (end - start)).clamp(0.0, 1.0),
                )
              : 1.0;
          return Opacity(
            opacity: v,
            child: Transform.translate(
              offset: Offset(0, 24 * (1 - v)),
              child: child,
            ),
          );
        },
        child: child,
      );
    }

    return Column(
      children: [
        staggered(
          0.10,
          0.65,
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: T.fontDisplay,
              fontSize: 34,
              height: 1.1,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
              color: T.ink,
            ),
          ),
        ),
        const SizedBox(height: 14),
        staggered(
          0.30,
          0.95,
          Text(
            body,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: T.font,
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w600,
              color: T.inkSoft,
            ),
          ),
        ),
      ],
    );
  }
}

/// Soft pulsing wash behind the hero.
class _Halo extends StatelessWidget {
  const _Halo({required this.t});
  final double t;

  @override
  Widget build(BuildContext context) {
    final pulse = 0.9 + 0.1 * math.sin(t * 2 * math.pi);
    return Transform.scale(
      scale: pulse,
      child: Container(
        width: 230,
        height: 230,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [T.accentHalo, T.accent.withAlpha(0)],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// A large soft accent blob that drifts with the swipe and gently breathes.
// ---------------------------------------------------------------------------

class _DriftingBlob extends StatelessWidget {
  const _DriftingBlob({required this.pos, required this.loop});

  final double pos;
  final AnimationController loop;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: loop,
      builder: (context, _) {
        final size = MediaQuery.sizeOf(context);
        final breathe = 0.95 + 0.05 * math.sin(loop.value * 2 * math.pi);
        return Positioned(
          left: size.width * 0.16 - pos * 90,
          top: size.height * 0.02 + math.sin(loop.value * 2 * math.pi) * 14,
          child: Transform.scale(
            scale: breathe,
            child: Container(
              width: size.width * 0.74,
              height: size.width * 0.74,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [T.accent.withAlpha(38), T.accent.withAlpha(0)],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Page indicator — dots that stretch into a pill for the active page.
// ---------------------------------------------------------------------------

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.pos});

  final int count;
  final double pos;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final p = (1 - (pos - i).abs()).clamp(0.0, 1.0);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8 + 22 * p,
          height: 8,
          decoration: BoxDecoration(
            color: Color.lerp(T.inkFaint, T.accent, p),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom call-to-action button — gently pulses its glow.
// ---------------------------------------------------------------------------

class _CtaButton extends StatefulWidget {
  const _CtaButton({required this.isLast, required this.onTap});

  final bool isLast;
  final VoidCallback onTap;

  @override
  State<_CtaButton> createState() => _CtaButtonState();
}

class _CtaButtonState extends State<_CtaButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, child) {
          return Container(
            height: 58,
            decoration: BoxDecoration(
              color: T.accent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: child,
          );
        },
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Row(
              key: ValueKey(widget.isLast),
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.isLast ? 'Get started' : 'Next',
                  style: const TextStyle(
                    fontFamily: T.fontDisplay,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  widget.isLast
                      ? Icons.arrow_forward_rounded
                      : Icons.chevron_right_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
