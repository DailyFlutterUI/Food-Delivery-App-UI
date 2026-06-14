import 'package:flutter/material.dart';

import 'ehailing_theme.dart';
import 'service_screen.dart';
import 'service_mode.dart';

/// The home hub. Shows the three services as choices; tapping one opens that
/// service's own screen, themed in its single accent.
class EHailingLanding extends StatelessWidget {
  const EHailingLanding({super.key});

  void _open(BuildContext context, ServiceMode mode) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 360),
        reverseTransitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (_, _, _) => ServiceScreen(mode: mode),
        transitionsBuilder: (_, anim, _, child) {
          final curved =
              CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: E.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            const _Header(),
            const SizedBox(height: 26),
            const Text('What can we\nmove for you?', style: E.display),
            const SizedBox(height: 22),
            ...ServiceMode.values.map((m) {
              final cfg = ModeConfig.all[m]!;
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _ServiceCard(
                  cfg: cfg,
                  onTap: () => _open(context, m),
                ),
              );
            }),
            const SizedBox(height: 6),
            const _PromoCard(),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Good evening', style: E.sub),
            SizedBox(height: 2),
            Text('Aisyah', style: E.h1),
          ],
        ),
        const Spacer(),
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: E.surface,
            shape: BoxShape.circle,
            border: Border.all(color: E.hairline),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Text(
            'A',
            style: TextStyle(
              fontFamily: E.fontFamily,
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: E.ink,
            ),
          ),
        ),
      ],
    );
  }
}

/// A large, tappable card for one service. Restrained: one accent, a soft tint
/// fill, a watermark glyph for depth, and a clear price hint.
class _ServiceCard extends StatefulWidget {
  const _ServiceCard({required this.cfg, required this.onTap});
  final ModeConfig cfg;
  final VoidCallback onTap;

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final cfg = widget.cfg;
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.975 : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: Container(
          height: 124,
          decoration: BoxDecoration(
            color: cfg.accentSoft,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: cfg.accent.withValues(alpha: 0.16)),
          ),
          child: Stack(
            children: [
              // Watermark glyph bleeding off the right edge for subtle depth.
              Positioned(
                right: -14,
                bottom: -18,
                child: Icon(
                  cfg.icon,
                  size: 128,
                  color: cfg.accent.withValues(alpha: 0.10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: cfg.accent,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: cfg.accent.withValues(alpha: 0.32),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(cfg.icon, color: Colors.white, size: 27),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(cfg.label, style: E.cardTitle),
                          const SizedBox(height: 3),
                          Text(
                            cfg.tagline,
                            style: E.sub,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 7),
                          Text(
                            cfg.priceHint,
                            style: E.label.copyWith(
                              color: cfg.accent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: cfg.accent.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_forward_rounded,
                          size: 18, color: cfg.accent),
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

class _PromoCard extends StatelessWidget {
  const _PromoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: E.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: E.hairline),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_offer_rounded, size: 22, color: E.muted),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('20% off your next 3 rides', style: E.body),
                SizedBox(height: 2),
                Text('Welcome offer · ends Sunday', style: E.sub),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: E.muted),
        ],
      ),
    );
  }
}
