import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'delivery_model.dart';
import 'delivery_theme.dart';

/// Builds the delivery route as a smooth curve across the map, in the painter's
/// coordinate space. Shared by the painter (to draw it) and the widget (to read
/// the vehicle's position/heading along it) so they never drift apart.
Path buildRoutePath(Size size) {
  final w = size.width, h = size.height;
  final p = Path()..moveTo(w * 0.12, h * 0.84); // warehouse, lower-left
  p.cubicTo(
    w * 0.30, h * 0.78,
    w * 0.22, h * 0.55,
    w * 0.44, h * 0.52,
  );
  p.cubicTo(
    w * 0.66, h * 0.49,
    w * 0.58, h * 0.26,
    w * 0.82, h * 0.20, // home, upper-right
  );
  return p;
}

/// The stylized live map used across the Driver-Assigned → On-the-Way → Near
/// stages. The route draws in once, then a vehicle marker travels along it; near
/// the end the destination pin pulses and the whole map gives a nervous shake.
class RouteMap extends StatefulWidget {
  const RouteMap({super.key, required this.stage});

  final Stage stage;

  @override
  State<RouteMap> createState() => _RouteMapState();
}

class _RouteMapState extends State<RouteMap> with TickerProviderStateMixin {
  // Continuous ambient loop: dashed road flow, marker pulse, shake phase.
  late final AnimationController _ambient = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat();

  // Route draw-in (plays once when the map appears).
  late final AnimationController _draw = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  // Vehicle travel along the route — retargeted on each stage change.
  late final AnimationController _travel = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  );
  late Animation<double> _vehicle = const AlwaysStoppedAnimation(0);
  double _vehicleValue = 0;

  static double _targetFor(Stage s) {
    switch (s) {
      case Stage.assigned:
        return 0.0;
      case Stage.onTheWay:
        return 0.82;
      case Stage.near:
        return 0.965;
      default:
        return 1.0;
    }
  }

  @override
  void initState() {
    super.initState();
    _vehicleValue = _targetFor(widget.stage);
    _vehicle = AlwaysStoppedAnimation(_vehicleValue);
    _vehicle.addListener(_tick);
    // If we open straight onto a map stage past "assigned", route is pre-drawn.
    _draw.value = widget.stage == Stage.assigned ? 0 : 1;
    if (widget.stage == Stage.assigned) _draw.forward();
  }

  void _tick() => setState(() => _vehicleValue = _vehicle.value);

  @override
  void didUpdateWidget(covariant RouteMap old) {
    super.didUpdateWidget(old);
    if (old.stage == widget.stage) return;
    // Draw the route the first time we have one.
    if (widget.stage == Stage.assigned && _draw.value == 0) _draw.forward();
    if (widget.stage.index > Stage.assigned.index && _draw.value < 1) {
      _draw.forward();
    }
    _retarget(_targetFor(widget.stage), nervous: widget.stage == Stage.near);
  }

  void _retarget(double to, {required bool nervous}) {
    _vehicle.removeListener(_tick);
    _travel.duration = Duration(
      milliseconds: nervous ? 800 : 1400,
    );
    _vehicle = Tween<double>(begin: _vehicleValue, end: to).animate(
      CurvedAnimation(
        parent: _travel,
        curve: nervous ? Curves.easeInOut : Curves.easeInOutCubic,
      ),
    )..addListener(_tick);
    _travel.forward(from: 0);
  }

  @override
  void dispose() {
    _ambient.dispose();
    _draw.dispose();
    _travel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isNear = widget.stage == Stage.near;
    // The hero clips this; we fill the full rect (full-bleed map).
    return AnimatedBuilder(
      animation: Listenable.merge([_ambient, _draw]),
      builder: (_, _) {
        // A subtle, decaying shake during the "near" stage.
        double dx = 0, dy = 0;
        if (isNear) {
          final ph = _ambient.value * 2 * math.pi;
          const intensity = 2.2;
          dx = math.sin(ph * 6) * intensity;
          dy = math.cos(ph * 7) * intensity * 0.7;
        }
        return Transform.translate(
          offset: Offset(dx, dy),
          child: CustomPaint(
            painter: _MapPainter(
              ambient: _ambient.value,
              draw: _draw.value,
              vehicleT: _vehicleValue,
              pulseDest: isNear,
              showVehicle: widget.stage != Stage.delivered,
            ),
            child: const SizedBox.expand(),
          ),
        );
      },
    );
  }
}

class _MapPainter extends CustomPainter {
  _MapPainter({
    required this.ambient,
    required this.draw,
    required this.vehicleT,
    required this.pulseDest,
    required this.showVehicle,
  });

  final double ambient;
  final double draw;
  final double vehicleT;
  final bool pulseDest;
  final bool showVehicle;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = D.mapBg);

    _paintWater(canvas, size);
    _paintParks(canvas, size);
    _paintRoads(canvas, size);
    _paintBuildings(canvas, size);

    final route = buildRoutePath(size);
    final metric = route.computeMetrics().first;
    final len = metric.length;

    // Route casing + drawn portion — a dark, rounded line like the reference.
    final drawn = metric.extractPath(0, len * draw.clamp(0.0, 1.0));
    canvas.drawPath(
      drawn,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = Colors.white,
    );
    canvas.drawPath(
      drawn,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = D.route,
    );
    // Faint un-drawn remainder so the path is hinted ahead of the truck.
    if (draw >= 1) {
      final ahead = metric.extractPath(len * vehicleT, len);
      canvas.drawPath(
        ahead,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5.5
          ..strokeCap = StrokeCap.round
          ..color = D.route.withValues(alpha: 0.16),
      );
    }

    // Endpoints.
    final origin = metric.getTangentForOffset(0)!.position;
    final dest = metric.getTangentForOffset(len)!.position;
    _paintWarehouse(canvas, origin);
    _paintDestination(canvas, dest);

    // Vehicle — a black disc with an orange heading arrow, like the reference.
    if (showVehicle && draw >= 1) {
      final t = metric.getTangentForOffset(len * vehicleT.clamp(0.0, 1.0))!;
      _paintVehicle(canvas, t.position, t.angle);
    }
  }

  // -- realistic map base: water, parks, layered roads, building footprints ---

  /// A river / canal curving across one corner, with a soft bank.
  void _paintWater(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final river = Path()
      ..moveTo(w * 1.05, h * -0.05)
      ..cubicTo(w * 0.74, h * 0.10, w * 0.86, h * 0.34, w * 0.66, h * 0.44)
      ..cubicTo(w * 0.50, h * 0.52, w * 0.58, h * 0.74, w * 0.40, h * 0.86)
      ..cubicTo(w * 0.30, h * 0.93, w * 0.34, h * 1.06, w * 0.30, h * 1.10)
      ..lineTo(w * 1.2, h * 1.2)
      ..close();
    // Soft bank then water body.
    canvas.drawPath(
      river,
      Paint()
        ..color = D.mapWater.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawPath(river, Paint()..color = D.mapWater);
  }

  /// One or two green parks with rounded, organic edges.
  void _paintParks(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final park = Paint()..color = D.mapPark;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.04, h * 0.06, w * 0.26, h * 0.16),
        const Radius.circular(16),
      ),
      park,
    );
    canvas.drawCircle(Offset(w * 0.20, h * 0.66), w * 0.12, park);
  }

  /// Two-tier road network: a wide diagonal avenue plus a minor grid, each with
  /// a soft casing so the asphalt reads as raised above the blocks.
  void _paintRoads(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    void stroke(Path p, double width, Color color) {
      canvas.drawPath(
        p,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = color,
      );
    }

    // Minor grid (thin), offset so it doesn't look mechanical.
    final minor = Path();
    for (final fx in [0.30, 0.56, 0.80]) {
      minor.moveTo(w * fx, 0);
      minor.lineTo(w * fx, h);
    }
    for (final fy in [0.22, 0.40, 0.60, 0.80]) {
      minor.moveTo(0, h * fy);
      minor.lineTo(w, h * fy);
    }
    stroke(minor, 7, D.mapRoadEdge);
    stroke(minor, 4.5, D.mapRoadMinor);

    // A wide diagonal avenue sweeping across — the "main road".
    final avenue = Path()
      ..moveTo(-w * 0.1, h * 0.92)
      ..cubicTo(w * 0.30, h * 0.70, w * 0.40, h * 0.40, w * 1.1, h * 0.16);
    stroke(avenue, 16, D.mapRoadEdge);
    stroke(avenue, 12, D.mapRoad);

    // A second avenue crossing it.
    final avenue2 = Path()
      ..moveTo(w * 0.06, -h * 0.05)
      ..cubicTo(w * 0.18, h * 0.30, w * 0.30, h * 0.55, w * 0.16, h * 1.05);
    stroke(avenue2, 13, D.mapRoadEdge);
    stroke(avenue2, 9.5, D.mapRoad);
  }

  /// Building footprints clustered into blocks, with a faint drop shadow for a
  /// gentle sense of height. Deterministic from a fixed seed.
  void _paintBuildings(Canvas canvas, Size size) {
    final rnd = math.Random(7);
    final palette = [D.mapBlock, D.mapBlockAlt, D.mapBlockWarm];
    const cols = 6, rows = 9;
    final cw = size.width / cols, ch = size.height / rows;
    final shadow = Paint()
      ..color = D.ink.withValues(alpha: 0.05)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (rnd.nextDouble() < 0.42) continue; // gaps for roads / open land
        final pad = 4.0 + rnd.nextDouble() * 5;
        final jx = (rnd.nextDouble() - 0.5) * 4;
        final jy = (rnd.nextDouble() - 0.5) * 4;
        final rectB = Rect.fromLTWH(
          c * cw + pad + jx,
          r * ch + pad + jy,
          cw - pad * 2,
          ch - pad * 2,
        );
        if (rectB.width < 4 || rectB.height < 4) continue;
        final radius = Radius.circular(3 + rnd.nextDouble() * 4);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rectB.shift(const Offset(1.5, 2)), radius),
          shadow,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rectB, radius),
          Paint()..color = palette[rnd.nextInt(palette.length)],
        );
      }
    }
  }

  void _paintWarehouse(Canvas canvas, Offset c) {
    // A solid orange origin dot with a white core, like the reference.
    canvas.drawCircle(
        c, 12, Paint()..color = Colors.white);
    canvas.drawCircle(c, 9, Paint()..color = D.accent);
    canvas.drawCircle(c, 4, Paint()..color = Colors.white);
  }

  void _paintDestination(Canvas canvas, Offset c) {
    if (pulseDest) {
      final pulse = (ambient % 0.5) / 0.5; // 0..1 twice per loop
      final r = 14 + pulse * 30;
      canvas.drawCircle(
        c,
        r,
        Paint()..color = D.accentWarm.withValues(alpha: (1 - pulse) * 0.40),
      );
    }
    // Rounded marker pin (orange) with a white dot — matches the reference.
    final pin = Path();
    pin.moveTo(c.dx, c.dy + 7);
    pin.cubicTo(c.dx - 15, c.dy - 7, c.dx - 10, c.dy - 28, c.dx, c.dy - 28);
    pin.cubicTo(c.dx + 10, c.dy - 28, c.dx + 15, c.dy - 7, c.dx, c.dy + 7);
    pin.close();
    canvas.drawPath(
      pin,
      Paint()
        ..color = D.ink.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawPath(pin, Paint()..color = D.accent);
    canvas.drawCircle(Offset(c.dx, c.dy - 18), 6, Paint()..color = Colors.white);
  }

  void _paintVehicle(Canvas canvas, Offset c, double angle) {
    // Soft ground shadow.
    canvas.drawOval(
      Rect.fromCenter(center: c.translate(0, 15), width: 28, height: 9),
      Paint()
        ..color = D.ink.withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    // Black disc.
    canvas.drawCircle(c, 19, Paint()..color = D.dark);
    canvas.drawCircle(
      c,
      19,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = Colors.white,
    );
    // Orange heading arrow, rotated along the route direction.
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(angle);
    final arrow = Path()
      ..moveTo(7, 0)
      ..lineTo(-5, -6)
      ..lineTo(-2, 0)
      ..lineTo(-5, 6)
      ..close();
    canvas.drawPath(arrow, Paint()..color = D.accent);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MapPainter old) =>
      old.ambient != ambient ||
      old.draw != draw ||
      old.vehicleT != vehicleT ||
      old.pulseDest != pulseDest;
}
