import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// The signature pill button: iridescent gradient fill with a soft glow,
/// an animated sheen that sweeps across on a slow loop, and a press scale.
class GradientButton extends StatefulWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = 58,
    this.enabled = true,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final double height;
  final bool enabled;

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sheen;
  bool _down = false;

  @override
  void initState() {
    super.initState();
    _sheen = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
  }

  @override
  void dispose() {
    _sheen.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.enabled ? (_) => setState(() => _down = true) : null,
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: widget.enabled ? widget.onPressed : null,
      child: AnimatedScale(
        scale: _down ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOut,
        child: Opacity(
          opacity: widget.enabled ? 1 : 0.5,
          child: Container(
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.height / 2),
              gradient: AppGradients.accent,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.height / 2),
              child: AnimatedBuilder(
                animation: _sheen,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // moving sheen
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _SheenPainter(_sheen.value),
                        ),
                      ),
                      // top inner highlight
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: widget.height / 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withValues(alpha: 0.22),
                                Colors.white.withValues(alpha: 0),
                              ],
                            ),
                          ),
                        ),
                      ),
                      child!,
                    ],
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, size: 20, color: Colors.white),
                      const SizedBox(width: 10),
                    ],
                    Text(
                      widget.label,
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SheenPainter extends CustomPainter {
  _SheenPainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    // A diagonal band of light sweeping left -> right.
    final x = (t * 1.6 - 0.3) * size.width;
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.white.withValues(alpha: 0),
          Colors.white.withValues(alpha: 0.28),
          Colors.white.withValues(alpha: 0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(
        Rect.fromLTWH(x - size.width * 0.25, 0, size.width * 0.5, size.height),
      );
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _SheenPainter old) => old.t != t;
}
