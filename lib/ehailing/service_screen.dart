import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'ehailing_theme.dart';
import 'service_mode.dart';

/// A single service's booking screen: live map + a booking panel, all themed
/// in that service's one accent. Reached by tapping a card on the landing hub.
class ServiceScreen extends StatefulWidget {
  const ServiceScreen({super.key, required this.mode});

  final ServiceMode mode;

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  int _selectedOption = 0;

  static const _origin = LatLng(3.1390, 101.6869); // Kuala Lumpur
  static const _dest = LatLng(3.1578, 101.7120);

  ModeConfig get _cfg => ModeConfig.all[widget.mode]!;

  @override
  Widget build(BuildContext context) {
    final cfg = _cfg;
    // Re-theme this subtree so ripples / system accents match the mode.
    return Theme(
      data: E.theme(cfg.accent),
      child: Scaffold(
        backgroundColor: E.bg,
        body: Stack(
          children: [
            _Map(accent: cfg.accent, origin: _origin, dest: _dest),
            IgnorePointer(
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [E.bg, E.bg.withValues(alpha: 0)],
                  ),
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Row(
                  children: [
                    _RoundIconButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 12),
                    _TitleChip(cfg: cfg),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: _BookingPanel(
                cfg: cfg,
                selected: _selectedOption,
                onSelectOption: (i) => setState(() => _selectedOption = i),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: E.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, size: 22, color: E.ink),
      ),
    );
  }
}

class _TitleChip extends StatelessWidget {
  const _TitleChip({required this.cfg});
  final ModeConfig cfg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: E.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(cfg.icon, size: 18, color: cfg.accent),
          const SizedBox(width: 8),
          Text(cfg.label, style: E.body),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Map background
// ─────────────────────────────────────────────────────────────────────────

class _Map extends StatelessWidget {
  const _Map({required this.accent, required this.origin, required this.dest});

  final Color accent;
  final LatLng origin;
  final LatLng dest;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: const MapOptions(
        initialCenter: LatLng(3.1480, 101.6995),
        initialZoom: 13.2,
        interactionOptions: InteractionOptions(
            flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag),
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'com.miniapp.ehailing',
          retinaMode: RetinaMode.isHighDensity(context),
        ),
        PolylineLayer(
          polylines: [
            Polyline(
              points: [origin, dest],
              strokeWidth: 4,
              color: accent.withValues(alpha: 0.85),
            ),
          ],
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: origin,
              width: 26,
              height: 26,
              child: _OriginDot(accent: accent),
            ),
            Marker(
              point: dest,
              width: 40,
              height: 48,
              alignment: Alignment.topCenter,
              child: _DestPin(accent: accent),
            ),
          ],
        ),
      ],
    );
  }
}

class _OriginDot extends StatelessWidget {
  const _OriginDot({required this.accent});
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: E.surface,
        shape: BoxShape.circle,
        border: Border.all(color: accent, width: 5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
    );
  }
}

class _DestPin extends StatelessWidget {
  const _DestPin({required this.accent});
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: accent,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.place_rounded, color: Colors.white, size: 20),
        ),
        Container(width: 3, height: 12, color: accent),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Booking panel
// ─────────────────────────────────────────────────────────────────────────

class _BookingPanel extends StatelessWidget {
  const _BookingPanel({
    required this.cfg,
    required this.selected,
    required this.onSelectOption,
  });

  final ModeConfig cfg;
  final int selected;
  final ValueChanged<int> onSelectOption;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: E.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 28,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: E.hairline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(cfg.headline, style: E.h1),
              const SizedBox(height: 16),
              _RouteCard(cfg: cfg),
              const SizedBox(height: 18),
              SizedBox(
                height: 92,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  itemCount: cfg.options.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 12),
                  itemBuilder: (context, i) => _OptionCard(
                    option: cfg.options[i],
                    accent: cfg.accent,
                    accentSoft: cfg.accentSoft,
                    selected: i == selected,
                    onTap: () => onSelectOption(i),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              _Cta(cfg: cfg, option: cfg.options[selected]),
            ],
          ),
        ),
      ),
    );
  }
}

class _RouteCard extends StatelessWidget {
  const _RouteCard({required this.cfg});
  final ModeConfig cfg;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: E.fill,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          _RouteRow(
            dotColor: cfg.accent,
            isOrigin: true,
            label: cfg.originLabel,
            value: cfg.originValue,
            valueMuted: false,
          ),
          const Divider(height: 1, thickness: 1, color: E.hairline, indent: 48),
          _RouteRow(
            dotColor: E.muted,
            isOrigin: false,
            label: cfg.destLabel,
            value: cfg.destHint,
            valueMuted: true,
          ),
        ],
      ),
    );
  }
}

class _RouteRow extends StatelessWidget {
  const _RouteRow({
    required this.dotColor,
    required this.isOrigin,
    required this.label,
    required this.value,
    required this.valueMuted,
  });

  final Color dotColor;
  final bool isOrigin;
  final String label;
  final String value;
  final bool valueMuted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Center(
              child: isOrigin
                  ? Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                      ),
                    )
                  : Icon(Icons.place_rounded, size: 18, color: dotColor),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: E.label),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: E.body.copyWith(color: valueMuted ? E.muted : E.ink),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: E.muted, size: 20),
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.option,
    required this.accent,
    required this.accentSoft,
    required this.selected,
    required this.onTap,
  });

  final ServiceOption option;
  final Color accent;
  final Color accentSoft;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 150,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? accentSoft : E.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? accent : E.hairline,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(option.icon, size: 22, color: selected ? accent : E.ink),
                const Spacer(),
                Text(
                  option.eta,
                  style: E.label.copyWith(color: selected ? accent : E.muted),
                ),
              ],
            ),
            const Spacer(),
            Text(option.title, style: E.body),
            const SizedBox(height: 1),
            Text(
              option.price,
              style: E.sub.copyWith(
                color: selected ? accent : E.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Cta extends StatelessWidget {
  const _Cta({required this.cfg, required this.option});
  final ModeConfig cfg;
  final ServiceOption option;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: cfg.accent,
              content: Text(
                '${cfg.cta} · ${option.title} (${option.price})',
                style: const TextStyle(
                  fontFamily: E.fontFamily,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          );
      },
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: cfg.accent,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: cfg.accent.withValues(alpha: 0.32),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              cfg.cta,
              style: const TextStyle(
                fontFamily: E.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded,
                color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}
