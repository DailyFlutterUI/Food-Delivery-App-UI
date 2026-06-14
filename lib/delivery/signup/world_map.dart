import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'signup_data.dart';
import 'signup_theme.dart';

// ===========================================================================
// Stylized world map — a "global shipping" dot-matrix planet on a dark field.
// Land reads as a fine grid of dots (think the maps on premium fintech sites);
// the chosen country glows orange. The "viral moment" flies the whole world
// down into that country.
// ===========================================================================

/// Continent + island outlines as lon/lat vertices (closed polygons). Coarse on
/// purpose — the dot grid samples them, so exact borders don't matter.
const Map<String, List<Offset>> _continents = {
  'north_america': [
    Offset(-168, 65), Offset(-160, 71), Offset(-140, 70), Offset(-120, 72),
    Offset(-95, 70), Offset(-82, 73), Offset(-64, 60), Offset(-56, 52),
    Offset(-66, 45), Offset(-70, 41), Offset(-75, 35), Offset(-81, 25),
    Offset(-97, 18), Offset(-105, 22), Offset(-110, 30), Offset(-117, 33),
    Offset(-124, 40), Offset(-124, 48), Offset(-131, 55), Offset(-150, 59),
    Offset(-165, 60),
  ],
  'south_america': [
    Offset(-80, 8), Offset(-70, 12), Offset(-60, 8), Offset(-50, 0),
    Offset(-44, -3), Offset(-39, -13), Offset(-38, -22), Offset(-48, -25),
    Offset(-55, -34), Offset(-58, -41), Offset(-66, -46), Offset(-72, -52),
    Offset(-74, -50), Offset(-72, -42), Offset(-71, -33), Offset(-71, -24),
    Offset(-75, -15), Offset(-79, -5), Offset(-81, 1),
  ],
  'europe': [
    Offset(-10, 36), Offset(-9, 43), Offset(-2, 44), Offset(3, 43),
    Offset(12, 44), Offset(16, 40), Offset(28, 41), Offset(40, 47),
    Offset(40, 55), Offset(30, 60), Offset(30, 67), Offset(22, 70),
    Offset(12, 65), Offset(6, 62), Offset(-1, 58), Offset(2, 51),
    Offset(-2, 48), Offset(-9, 47),
  ],
  'africa': [
    Offset(-16, 15), Offset(-12, 22), Offset(-5, 31), Offset(10, 34),
    Offset(20, 32), Offset(32, 31), Offset(35, 24), Offset(43, 12),
    Offset(51, 12), Offset(48, 2), Offset(41, -5), Offset(40, -16),
    Offset(33, -26), Offset(25, -34), Offset(18, -35), Offset(15, -28),
    Offset(12, -18), Offset(8, -5), Offset(3, 5), Offset(-8, 9),
    Offset(-16, 13),
  ],
  'asia': [
    Offset(28, 41), Offset(35, 46), Offset(46, 48), Offset(56, 52),
    Offset(62, 58), Offset(72, 60), Offset(84, 62), Offset(98, 62),
    Offset(112, 60), Offset(126, 60), Offset(140, 58), Offset(150, 62),
    Offset(164, 66), Offset(176, 69), Offset(170, 60), Offset(156, 52),
    Offset(143, 45), Offset(141, 38), Offset(133, 34), Offset(123, 30),
    Offset(121, 22), Offset(109, 18), Offset(101, 12), Offset(96, 8),
    Offset(93, 18), Offset(89, 22), Offset(81, 13), Offset(76, 22),
    Offset(69, 24), Offset(61, 25), Offset(56, 30), Offset(46, 35),
    Offset(40, 41), Offset(33, 42),
  ],
  'australia': [
    Offset(113, -22), Offset(122, -18), Offset(130, -12), Offset(137, -12),
    Offset(143, -11), Offset(147, -18), Offset(151, -25), Offset(153, -32),
    Offset(146, -39), Offset(139, -38), Offset(132, -32), Offset(125, -33),
    Offset(118, -35), Offset(115, -30), Offset(113, -26),
  ],
  // Small island groups so SE-Asia / Japan / UK actually carry land dots.
  'sea_islands': [
    Offset(95, 6), Offset(100, 4), Offset(106, 1), Offset(113, -3),
    Offset(122, -4), Offset(130, -3), Offset(126, 2), Offset(120, 6),
    Offset(112, 8), Offset(103, 8),
  ],
  'japan': [
    Offset(140, 42), Offset(141, 38), Offset(140, 35), Offset(135, 34),
    Offset(137, 38), Offset(139, 41),
  ],
  'uk': [
    Offset(-5, 50), Offset(-3, 53), Offset(-4, 58), Offset(-7, 56),
    Offset(-6, 51),
  ],
  'nz': [
    Offset(167, -44), Offset(172, -41), Offset(176, -39), Offset(174, -45),
    Offset(169, -46),
  ],
};

/// lon/lat → 0..1 normalized (equirectangular).
Offset _project(Offset lonLat) =>
    Offset((lonLat.dx + 180) / 360, (90 - lonLat.dy) / 180);

bool _inPoly(double x, double y, List<Offset> poly) {
  bool inside = false;
  for (int i = 0, j = poly.length - 1; i < poly.length; j = i++) {
    final xi = poly[i].dx, yi = poly[i].dy, xj = poly[j].dx, yj = poly[j].dy;
    final hit = ((yi > y) != (yj > y)) &&
        (x < (xj - xi) * (y - yi) / (yj - yi) + xi);
    if (hit) inside = !inside;
  }
  return inside;
}

/// One land dot: normalized position + a stable jitter seed for organic feel.
class _Dot {
  const _Dot(this.p, this.seed);
  final Offset p; // 0..1
  final double seed; // 0..1
}

/// The land dot field, sampled once from the polygons and cached.
List<_Dot>? _dotCache;
List<_Dot> get _landDots {
  if (_dotCache != null) return _dotCache!;
  final list = <_Dot>[];
  const step = 2.0; // degrees between dots
  final rnd = math.Random(7);
  for (double lon = -180; lon <= 180; lon += step) {
    for (double lat = -58; lat <= 82; lat += step) {
      for (final poly in _continents.values) {
        if (_inPoly(lon, lat, poly)) {
          list.add(_Dot(_project(Offset(lon, lat)), rnd.nextDouble()));
          break;
        }
      }
    }
  }
  _dotCache = list;
  return list;
}

/// The animated world-map hero. Idles as a softly twinkling dotted planet with
/// the target country glowing, until [zoom] flips true — then it flies the
/// camera down into the country and calls [onArrived].
class WorldMapView extends StatefulWidget {
  const WorldMapView({
    super.key,
    required this.country,
    required this.zoom,
    this.onArrived,
  });

  final Country country;
  final bool zoom;
  final VoidCallback? onArrived;

  @override
  State<WorldMapView> createState() => _WorldMapViewState();
}

class _WorldMapViewState extends State<WorldMapView>
    with TickerProviderStateMixin {
  late final AnimationController _ambient = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat();

  late final AnimationController _fly = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2800),
  )..addStatusListener((s) {
      if (s == AnimationStatus.completed) widget.onArrived?.call();
    });

  // Pulled back from a tight crop so the surrounding landmass stays visible —
  // the country reads as a real place on the map, not an empty patch of ocean.
  static const double _zoomScale = 3.6;

  @override
  void initState() {
    super.initState();
    if (widget.zoom) _fly.forward();
  }

  @override
  void didUpdateWidget(covariant WorldMapView old) {
    super.didUpdateWidget(old);
    if (widget.zoom && !old.zoom) _fly.forward(from: 0);
  }

  @override
  void dispose() {
    _ambient.dispose();
    _fly.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final vp = Size(c.maxWidth, c.maxHeight);
        final mapW = vp.width * 1.34;
        final mapH = mapW / 2;
        final target = widget.country.norm;
        final focusLocal = Offset(target.dx * mapW, target.dy * mapH);
        final childCenter = Offset(mapW / 2, mapH / 2);
        final screenCenter = Offset(vp.width / 2, vp.height / 2);

        return AnimatedBuilder(
          animation: Listenable.merge([_ambient, _fly]),
          builder: (context, _) {
            final t = Curves.easeInOutCubic.transform(_fly.value);
            final scale = ui.lerpDouble(1.0, _zoomScale, t)!;
            final focus = Offset.lerp(childCenter, focusLocal, t)!;
            final breathe = (1 - t) * math.sin(_ambient.value * 2 * math.pi) * 4;

            final m = Matrix4.identity()
              ..translateByDouble(
                  screenCenter.dx, screenCenter.dy + breathe, 0, 1)
              ..scaleByDouble(scale, scale, 1, 1)
              ..translateByDouble(-focus.dx, -focus.dy, 0, 1);

            final markerScreen = MatrixUtils.transformPoint(m, focusLocal);
            final reveal = ((t - 0.45) / 0.55).clamp(0.0, 1.0);

            return ClipRect(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _SpacePainter(
                        twinkle: _ambient.value,
                        warmth: t,
                        glowAt: markerScreen,
                      ),
                    ),
                  ),
                  Transform(
                    transform: m,
                    child: SizedBox(
                      width: mapW,
                      height: mapH,
                      child: CustomPaint(
                        painter: _WorldDotPainter(
                          target: target,
                          ambient: _ambient.value,
                          zoomT: t,
                        ),
                      ),
                    ),
                  ),
                  // Marker box: its bottom-centre (the pin tip) sits on the city.
                  Positioned(
                    left: markerScreen.dx - 80,
                    top: markerScreen.dy - 150,
                    width: 160,
                    height: 150,
                    child: IgnorePointer(
                      child: _Marker(
                        reveal: reveal,
                        pulse: _ambient.value,
                        idle: _fly.value == 0,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ===========================================================================
// Marker (overlay — constant screen size, glued to the city)
// ===========================================================================

class _Marker extends StatelessWidget {
  const _Marker({
    required this.reveal,
    required this.pulse,
    required this.idle,
  });

  final double reveal;
  final double pulse;
  final bool idle;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _MarkerPainter(reveal: reveal, pulse: pulse, idle: idle),
    );
  }
}

/// Draws the location marker with its tip anchored to the bottom-centre of the
/// box (which the parent positions exactly on the city). Idle: a soft pulsing
/// beacon. During the flight: expanding rings + a refined pin that drops in.
class _MarkerPainter extends CustomPainter {
  _MarkerPainter({
    required this.reveal,
    required this.pulse,
    required this.idle,
  });

  final double reveal;
  final double pulse;
  final bool idle;

  @override
  void paint(Canvas canvas, Size size) {
    final tip = Offset(size.width / 2, size.height); // the city point

    if (idle) {
      _beacon(canvas, tip);
      return;
    }
    if (reveal <= 0) return;

    // Expanding ground rings once the pin nears landing.
    if (reveal > 0.75) {
      final p = (pulse % 0.5) / 0.5;
      canvas.drawCircle(
        tip,
        10 + p * 34,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..color = S.accent.withValues(alpha: (1 - p) * 0.45 * reveal),
      );
    }

    final settle = Curves.easeOutBack.transform(reveal.clamp(0.0, 1.0));
    final dropY = (1 - settle) * 24; // pin falls onto the tip
    _pin(canvas, tip.translate(0, -dropY), reveal.clamp(0.0, 1.0));
  }

  void _beacon(Canvas canvas, Offset c) {
    for (final off in [0.0, 0.25]) {
      final p = ((pulse + off) % 0.5) / 0.5;
      canvas.drawCircle(
        c,
        7 + p * 30,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..color = S.accent.withValues(alpha: (1 - p) * 0.45),
      );
    }
    canvas.drawCircle(c, 9, Paint()..color = S.accent.withValues(alpha: 0.22));
    canvas.drawCircle(c, 5, Paint()..color = Colors.white);
    canvas.drawCircle(c, 2.6, Paint()..color = S.accent);
  }

  /// A clean modern teardrop pin: solid accent body, soft ground shadow, a
  /// white "hole", and a thin rim so it reads crisply on the dark map.
  void _pin(Canvas canvas, Offset tip, double opacity) {
    const r = 15.0;
    final headC = Offset(tip.dx, tip.dy - 40);

    // Soft contact shadow on the ground.
    canvas.drawOval(
      Rect.fromCenter(center: tip.translate(0, 2), width: 26, height: 9),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35 * opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    final body = Path()..moveTo(tip.dx, tip.dy);
    body.quadraticBezierTo(headC.dx - r, headC.dy + r * 1.05, headC.dx - r, headC.dy);
    body.arcToPoint(Offset(headC.dx + r, headC.dy),
        radius: const Radius.circular(r), clockwise: true);
    body.quadraticBezierTo(headC.dx + r, headC.dy + r * 1.05, tip.dx, tip.dy);
    body.close();

    // Drop shadow.
    canvas.drawPath(
      body.shift(const Offset(0, 4)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.30 * opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    // Solid body (single colour — no gradient).
    canvas.drawPath(body, Paint()..color = S.accent.withValues(alpha: opacity));
    // Thin crisp rim.
    canvas.drawPath(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = S.accentDeep.withValues(alpha: opacity),
    );
    // White hole + accent centre.
    canvas.drawCircle(
        headC, 6, Paint()..color = Colors.white.withValues(alpha: opacity));
    canvas.drawCircle(
        headC, 2.6, Paint()..color = S.accent.withValues(alpha: opacity));
  }

  @override
  bool shouldRepaint(_MarkerPainter old) =>
      old.reveal != reveal || old.pulse != pulse || old.idle != idle;
}

// ===========================================================================
// Backdrop
// ===========================================================================

/// Deep space: a dark vertical wash, a cool planetary core glow, twinkling
/// stars, and a warm focal glow under the marker that blooms as we arrive.
class _SpacePainter extends CustomPainter {
  _SpacePainter({
    required this.twinkle,
    required this.warmth,
    required this.glowAt,
  });

  final double twinkle;
  final double warmth;
  final Offset glowAt;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF14161D), Color(0xFF0A0B0F)],
        ).createShader(rect),
    );

    // Cool planetary halo behind the globe (fades out as we dive in).
    final core = Offset(size.width / 2, size.height * 0.46);
    final coreR = size.width * 0.7;
    canvas.drawCircle(
      core,
      coreR,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF2A3A5A).withValues(alpha: 0.30 * (1 - warmth)),
            const Color(0xFF2A3A5A).withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: core, radius: coreR)),
    );

    // Stars.
    final rnd = math.Random(42);
    for (int i = 0; i < 110; i++) {
      final x = rnd.nextDouble() * size.width;
      final y = rnd.nextDouble() * size.height;
      final big = rnd.nextDouble() < 0.12;
      final phase = rnd.nextDouble();
      final a = 0.12 +
          0.5 * (0.5 + 0.5 * math.sin((twinkle + phase) * 2 * math.pi));
      canvas.drawCircle(
        Offset(x, y),
        big ? 1.5 : 0.8,
        Paint()..color = Colors.white.withValues(alpha: a * 0.7),
      );
    }

    // A restrained warm halo at the landing point — enough to feel the arrival
    // without washing out the land dots beneath it.
    if (warmth > 0.02) {
      final r = 60 + warmth * 150;
      canvas.drawCircle(
        glowAt,
        r,
        Paint()
          ..shader = RadialGradient(
            colors: [
              S.accent.withValues(alpha: 0.14 * warmth),
              S.accent.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: glowAt, radius: r)),
      );
    }
  }

  @override
  bool shouldRepaint(_SpacePainter old) =>
      old.twinkle != twinkle || old.warmth != warmth || old.glowAt != glowAt;
}

// ===========================================================================
// The dotted planet
// ===========================================================================

class _WorldDotPainter extends CustomPainter {
  _WorldDotPainter({
    required this.target,
    required this.ambient,
    required this.zoomT,
  });

  final Offset target; // normalized 0..1
  final double ambient;
  final double zoomT;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final spacing = w * (2.0 / 360);
    final baseR = spacing * 0.24;
    final paint = Paint();

    // The map is equirectangular over a 2:1 box, so one degree of lon and lat
    // map to the same pixel distance — a circular cluster stays circular.
    final center = Offset(target.dx * w, target.dy * h);

    // The chosen country lights up as a generous dotted patch — big enough that
    // it clearly reads as a landmass around the pin, not a speck under it.
    const rings = 14;
    final litR = spacing * rings;

    // 1) The world — quiet grey land dots. Dots inside the lit area are skipped
    //    so they never show grey-under-orange.
    for (final d in _landDots) {
      final pos = Offset(d.p.dx * w, d.p.dy * h);
      if ((pos - center).distance < litR) continue;
      final tw = 0.5 + 0.5 * math.sin((ambient + d.seed) * 2 * math.pi);
      paint.color = Colors.white.withValues(alpha: 0.22 + 0.14 * tw);
      canvas.drawCircle(pos, baseR, paint);
    }

    // 2) The chosen country — a guaranteed orange dot field centred on it, so
    //    every country (even tiny island nations between the coarse polygons)
    //    reads as a real, lit-up region under the pin. Brightest at the core,
    //    fading smoothly into the dark at the edge.
    final lit = (0.8 + 0.2 * zoomT).clamp(0.0, 1.0);
    void litDot(Offset o, double r, double a) {
      paint.color = S.accent.withValues(alpha: a.clamp(0.0, 1.0));
      canvas.drawCircle(o, r, paint);
    }

    litDot(center, baseR * 1.6, lit);
    for (int ring = 1; ring <= rings; ring++) {
      final rr = spacing * ring;
      final count = ring * 6;
      final edge = ring / rings; // 0 (core) → 1 (rim)
      final fade = (1 - edge * edge) * lit; // smooth radial falloff
      final dotR = baseR * (1.3 - edge * 0.55);
      for (int i = 0; i < count; i++) {
        final ang = i / count * 2 * math.pi + ring * 0.5;
        litDot(
          center + Offset(math.cos(ang) * rr, math.sin(ang) * rr),
          dotR,
          fade,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_WorldDotPainter old) =>
      old.ambient != ambient || old.zoomT != zoomT || old.target != target;
}
