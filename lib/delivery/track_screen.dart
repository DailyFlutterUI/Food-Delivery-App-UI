import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'delivery_model.dart';
import 'delivery_theme.dart';
import 'route_map.dart';
import 'stage_heroes.dart';

class TrackScreen extends StatefulWidget {
  const TrackScreen({super.key});

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen>
    with TickerProviderStateMixin {
  final _store = deliveryStore;
  bool _auto = true;
  Timer? _timer;
  late final AnimationController _fastEta = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void initState() {
    super.initState();
    _store.addListener(_onChanged);
    _startAuto();
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _timer?.cancel();
    _store.removeListener(_onChanged);
    _fastEta.dispose();
    super.dispose();
  }

  // ---- auto-advance --------------------------------------------------------

  void _startAuto() {
    _timer?.cancel();
    if (_store.isLast) return;
    setState(() => _auto = true);
    _timer = Timer.periodic(const Duration(milliseconds: 2000), (_) => _tick());
  }

  void _stopAuto() {
    _timer?.cancel();
    _timer = null;
    if (mounted) setState(() => _auto = false);
  }

  void _tick() {
    if (!mounted) return;
    if (_store.isLast) {
      _stopAuto();
      return;
    }
    _store.advance();
    if (_store.isLast) _stopAuto(); // settle on Delivered and stop
  }

  void _toggleAuto() {
    HapticFeedback.selectionClick();
    if (_auto) {
      _stopAuto();
    } else if (_store.isLast) {
      _store.reset();
      _startAuto();
    } else {
      _startAuto();
    }
  }

  void _manualAdvance() {
    HapticFeedback.mediumImpact();
    if (_store.isLast) {
      _store.reset();
      _startAuto();
    } else {
      _store.advance();
      if (_store.isLast) _stopAuto();
    }
  }

  void _restart() {
    HapticFeedback.mediumImpact();
    _store.reset();
    _startAuto();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final size = media.size;
    final topInset = media.padding.top;
    final bottomInset = media.padding.bottom;

    final heroH = size.height * 0.46;
    const navH = 64.0;
    final navClearance = navH + 12 + bottomInset + 14;

    return Scaffold(
      backgroundColor: D.bg,
      body: Stack(
        children: [
          // Full-bleed hero (map / stage animation) across the top.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: heroH,
            child: ClipRect(child: _hero()),
          ),
          // Dark detail sheet, anchored to the bottom edge, overlapping the map.
          Positioned(
            top: heroH - 34,
            left: 0,
            right: 0,
            bottom: 0,
            child: _DetailSheet(
              store: _store,
              fastEta: _fastEta,
              bottomPadding: navClearance,
            ),
          ),

          // Floating top bar.
          Positioned(
            left: 16,
            right: 16,
            bottom: bottomInset + 12,
            child: _GlassNav(height: navH, onRestart: _restart),
          ),
        ],
      ),
    );
  }

  Widget _hero() {
    return GestureDetector(
      onTap: _manualAdvance,
      child: Container(
        color: D.bgSoft,
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: ScaleTransition(
                    scale: Tween(begin: 0.96, end: 1.0).animate(anim),
                    child: child,
                  ),
                ),
                child: _heroFor(_store.stage),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroFor(Stage s) {
    switch (s) {
      case Stage.confirmed:
        return const ConfirmedHero(key: ValueKey('confirmed'));
      case Stage.packed:
        return const WarehouseHero(key: ValueKey('packed'));
      case Stage.assigned:
      case Stage.onTheWay:
      case Stage.near:
        return RouteMap(key: const ValueKey('map'), stage: s);
      case Stage.delivered:
        return const DeliveredHero(key: ValueKey('delivered'));
    }
  }
}

// ===========================================================================
// Top bar
// ===========================================================================

class _TopBar extends StatelessWidget {
  const _TopBar({required this.auto, required this.onToggleAuto});

  final bool auto;
  final VoidCallback onToggleAuto;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      
       
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: D.card,
          shape: BoxShape.circle,
          boxShadow: D.cardShadow,
        ),
        child: Icon(icon, size: 17, color: D.ink),
      ),
    );
  }
}

// ===========================================================================
// Hero overlays
// ===========================================================================

/// The stage emoji in a soft, gently bobbing medallion with an accent halo.
class _EmojiBadge extends StatefulWidget {
  const _EmojiBadge({required this.emoji});
  final String emoji;

  @override
  State<_EmojiBadge> createState() => _EmojiBadgeState();
}

class _EmojiBadgeState extends State<_EmojiBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat();

  @override
  void dispose() {
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _loop,
      builder: (_, child) {
        final t = _loop.value * 2 * math.pi;
        return Transform.translate(
          offset: Offset(0, math.sin(t) * 3.5),
          child: child,
        );
      },
      child: Container(
        width: 52,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [D.accentHalo, D.accent.withAlpha(0)],
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          transitionBuilder: (c, a) => ScaleTransition(
            scale: Tween(
              begin: 0.4,
              end: 1.0,
            ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutBack)),
            child: FadeTransition(opacity: a, child: c),
          ),
          child: Container(
            key: ValueKey(widget.emoji),
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: D.card,
              shape: BoxShape.circle,
              boxShadow: D.cardShadow,
            ),
            child: Text(widget.emoji, style: const TextStyle(fontSize: 23)),
          ),
        ),
      ),
    );
  }
}

/// An animated caption over the hero: the stage title + live line, sliding in
/// on each change, with a slim journey-progress bar.
class _StatusCaption extends StatelessWidget {
  const _StatusCaption({required this.store});
  final DeliveryStore store;

  @override
  Widget build(BuildContext context) {
    final info = store.info;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // The pill morphs width to its content as the text changes.
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 420),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0, 0.35),
                end: Offset.zero,
              ).animate(anim),
              child: child,
            ),
          ),
          child: Container(
            key: ValueKey(info.title),
            padding: const EdgeInsets.fromLTRB(14, 10, 16, 11),
            decoration: BoxDecoration(
              color: D.card,
              borderRadius: BorderRadius.circular(18),
              boxShadow: D.cardShadow,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.title,
                  style: const TextStyle(
                    fontFamily: D.fontDisplay,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: D.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  info.line,
                  style: const TextStyle(
                    fontFamily: D.font,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: D.inkSoft,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Slim journey progress bar.
        SizedBox(
          width: 150,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                Container(height: 5, color: D.card.withValues(alpha: 0.75)),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: store.journey),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, _) => FractionallySizedBox(
                    widthFactor: v.clamp(0.0, 1.0),
                    child: Container(
                      height: 5,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [D.accentLight, D.accent],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EtaPill extends StatelessWidget {
  const _EtaPill({required this.store, required this.fastEta});

  final DeliveryStore store;
  final AnimationController fastEta;

  @override
  Widget build(BuildContext context) {
    Widget pill(String text, IconData icon) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: D.card,
        borderRadius: BorderRadius.circular(14),
        boxShadow: D.cardShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: D.accent),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontFamily: D.fontDisplay,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: D.ink,
            ),
          ),
        ],
      ),
    );

    if (store.stage == Stage.delivered) {
      return pill('Arrived', Icons.check_circle_rounded);
    }
    if (store.stage == Stage.near) {
      return AnimatedBuilder(
        animation: fastEta,
        builder: (_, _) {
          final secs = (170 * (1 - fastEta.value)).round();
          final mm = secs ~/ 60;
          final ss = (secs % 60).toString().padLeft(2, '0');
          return pill('$mm:$ss away', Icons.bolt_rounded);
        },
      );
    }
    final h = store.info.etaMinutes ~/ 60;
    final m = store.info.etaMinutes % 60;
    final text = h > 0 ? '${h}h ${m}m away' : '$m min away';
    return pill(text, Icons.schedule_rounded);
  }
}

// ===========================================================================
// Dark detail sheet (anchored, full height to the bottom edge)
// ===========================================================================

class _DetailSheet extends StatelessWidget {
  const _DetailSheet({
    required this.store,
    required this.fastEta,
    required this.bottomPadding,
  });

  final DeliveryStore store;
  final AnimationController fastEta;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: D.dark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
        boxShadow: D.darkShadow,
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 42,
            height: 5,
            decoration: BoxDecoration(
              color: D.darkHair,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(22, 18, 22, bottomPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Booking Id', style: _lbl),
                            const SizedBox(height: 3),
                            Text(
                              store.orderId,
                              style: const TextStyle(
                                fontFamily: D.fontDisplay,
                                fontSize: 23,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                                color: D.onDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Status', style: _lbl),
                          const SizedBox(height: 4),
                          _StatusPill(text: store.info.status),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _HStepper(store: store),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _Stacked(
                          label: 'Created, ${store.createdDate}',
                          value: store.fromCity,
                          align: CrossAxisAlignment.start,
                        ),
                      ),
                      Expanded(
                        child: _Stacked(
                          label: 'Estimated, ${store.estDate}',
                          value: store.toCity,
                          align: CrossAxisAlignment.end,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Divider(color: D.darkHair, height: 1),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(child: _kv('Customer', store.customer)),
                      Expanded(child: _kv('Order Cost', store.cost)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(child: _kv('Quantity', store.quantity)),
                      Expanded(child: _kv('Weight', store.weight)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _CourierRow(store: store),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(k, style: _lbl),
        const SizedBox(height: 4),
        Text(
          v,
          style: const TextStyle(
            fontFamily: D.fontDisplay,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: D.onDark,
          ),
        ),
      ],
    );
  }
}

const TextStyle _lbl = TextStyle(
  fontFamily: D.font,
  fontSize: 12,
  fontWeight: FontWeight.w600,
  color: D.onDarkMuted,
);

class _Stacked extends StatelessWidget {
  const _Stacked({
    required this.label,
    required this.value,
    required this.align,
  });

  final String label;
  final String value;
  final CrossAxisAlignment align;

  @override
  Widget build(BuildContext context) {
    final ta = align == CrossAxisAlignment.end
        ? TextAlign.right
        : TextAlign.left;
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(label, style: _lbl, textAlign: ta),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: ta,
          style: const TextStyle(
            fontFamily: D.fontDisplay,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: D.onDark,
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: D.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: D.accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontFamily: D.fontDisplay,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: D.ink,
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// Horizontal stepper
// ===========================================================================

class _HStepper extends StatelessWidget {
  const _HStepper({required this.store});
  final DeliveryStore store;

  @override
  Widget build(BuildContext context) {
    final stages = Stage.values;
    return Row(
      children: [
        for (int i = 0; i < stages.length; i++) ...[
          _StepNode(
            complete: store.isComplete(stages[i]),
            current: store.isCurrent(stages[i]),
          ),
          if (i != stages.length - 1)
            Expanded(child: _DottedConnector(filled: store.index > i)),
        ],
      ],
    );
  }
}

class _DottedConnector extends StatelessWidget {
  const _DottedConnector({required this.filled});
  final bool filled;

  @override
  Widget build(BuildContext context) {
    // The orange fill sweeps left→right as the stage advances past this gap.
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: filled ? 1.0 : 0.0),
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeOutCubic,
      builder: (_, v, _) => SizedBox(
        height: 3,
        child: CustomPaint(painter: _DotsPainter(fill: v)),
      ),
    );
  }
}

class _DotsPainter extends CustomPainter {
  _DotsPainter({required this.fill});
  final double fill; // 0..1 portion painted in accent

  @override
  void paint(Canvas canvas, Size size) {
    const r = 1.7;
    const gap = 7.0;
    final cutoff = size.width * fill;
    for (double x = 0; x <= size.width; x += gap) {
      final on = x <= cutoff;
      canvas.drawCircle(
        Offset(x, size.height / 2),
        on ? r + 0.3 : r,
        Paint()..color = on ? D.accent : D.darkHair,
      );
    }
  }

  @override
  bool shouldRepaint(_DotsPainter old) => old.fill != fill;
}

class _StepNode extends StatefulWidget {
  const _StepNode({required this.complete, required this.current});
  final bool complete;
  final bool current;

  @override
  State<_StepNode> createState() => _StepNodeState();
}

class _StepNodeState extends State<_StepNode>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const size = 26.0;
    if (widget.current) {
      return AnimatedBuilder(
        animation: _pulse,
        builder: (_, _) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: D.accent,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: D.accent.withValues(alpha: 0.30 + _pulse.value * 0.40),
                blurRadius: 4 + _pulse.value * 10,
                spreadRadius: _pulse.value * 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.local_shipping_rounded,
            size: 13,
            color: Colors.white,
          ),
        ),
      );
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: widget.complete ? D.accent : D.darkSoft,
        shape: BoxShape.circle,
        border: widget.complete
            ? null
            : Border.all(color: D.darkHair, width: 1.5),
      ),
      child: Icon(
        widget.complete ? Icons.check_rounded : Icons.circle,
        size: widget.complete ? 14 : 6,
        color: widget.complete ? Colors.white : D.onDarkMuted,
      ),
    );
  }
}

// ===========================================================================
// Courier row
// ===========================================================================

class _CourierRow extends StatelessWidget {
  const _CourierRow({required this.store});
  final DeliveryStore store;

  String get _initials {
    final parts = store.courier.split(' ');
    final a = parts.isNotEmpty && parts[0].isNotEmpty ? parts[0][0] : '';
    final b = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
    final res = '$a$b';
    return res.isEmpty ? '?' : res;
  }

  /// Gradient initials shown while the photo loads or if it can't be fetched.
  Widget _fallback() {
    return Container(
      width: 46,
      height: 46,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [D.accentLight, D.accent],
        ),
        shape: BoxShape.circle,
      ),
      child: Text(
        _initials,
        style: const TextStyle(
          fontFamily: D.fontDisplay,
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: D.darkSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: ClipOval(
              child: Image.network(
                store.courierAvatar,
                width: 46,
                height: 46,
                fit: BoxFit.cover,
                // Soft fade-in once the photo decodes.
                frameBuilder: (_, child, frame, wasSync) {
                  if (wasSync) return child;
                  return AnimatedOpacity(
                    opacity: frame == null ? 0 : 1,
                    duration: const Duration(milliseconds: 300),
                    child: child,
                  );
                },
                // Until it loads (or if offline) show the gradient initials.
                loadingBuilder: (_, child, progress) =>
                    progress == null ? child : _fallback(),
                errorBuilder: (_, _, _) => _fallback(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  store.courier,
                  style: const TextStyle(
                    fontFamily: D.fontDisplay,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: D.onDark,
                  ),
                ),
                const SizedBox(height: 1),
                Text(store.courierRole, style: _lbl),
              ],
            ),
          ),
          _CircleAction(
            icon: Icons.call_rounded,
            color: D.accent,
            onTap: () => HapticFeedback.lightImpact(),
          ),
          const SizedBox(width: 10),
          _CircleAction(
            icon: Icons.chat_bubble_rounded,
            color: D.card,
            iconColor: D.ink,
            onTap: () => HapticFeedback.lightImpact(),
          ),
        ],
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.icon,
    required this.color,
    this.iconColor = Colors.white,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, size: 20, color: iconColor),
      ),
    );
  }
}

// ===========================================================================
// Glass navigation bar — frosted, modern, floating
// ===========================================================================

class _GlassNav extends StatelessWidget {
  const _GlassNav({required this.height, required this.onRestart});

  final double height;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: D.ink.withValues(alpha: 0.18),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              // Dark frosted glass, a touch lighter than the sheet so it reads
              // as a raised element that belongs to the same surface.
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF2C2C32).withValues(alpha: 0.82),
                  const Color(0xFF1E1E22).withValues(alpha: 0.86),
                ],
              ),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.10),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const _NavItem(icon: Icons.home_rounded, label: 'Home'),
                const _NavItem(
                  icon: Icons.inventory_2_rounded,
                  label: 'Shipment',
                ),
                _CenterButton(onTap: onRestart),
                const _NavItem(
                  icon: Icons.near_me_rounded,
                  label: 'Tracking',
                  active: true,
                ),
                const _NavItem(icon: Icons.person_rounded, label: 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? D.accent : D.onDarkMuted;
    return GestureDetector(
      onTap: () => HapticFeedback.selectionClick(),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontFamily: D.fontDisplay,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterButton extends StatelessWidget {
  const _CenterButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -4),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(color: D.accent, shape: BoxShape.circle),
          child: const Icon(Icons.add, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}
