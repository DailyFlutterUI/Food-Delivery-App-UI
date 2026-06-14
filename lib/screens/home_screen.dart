import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/ambient_background.dart';
import '../widgets/common.dart';
import '../widgets/glass.dart';
import '../widgets/gradient_button.dart';
import '../widgets/progress_ring.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onOpenSettings});

  final VoidCallback onOpenSettings;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _category = 0;
  int _credits = 150;
  double _progress = 0.55;
  String _status = 'Making Note...';
  bool _generating = false;
  final _promptCtrl = TextEditingController();

  static const _categories = [
    (label: 'All', icon: null),
    (label: 'Notes', icon: Icons.description_outlined),
    (label: 'Quiz', icon: Icons.help_outline),
    (label: 'Chat', icon: Icons.chat_bubble_outline),
    (label: 'Audio', icon: Icons.graphic_eq),
    (label: 'Docs', icon: Icons.folder_open),
  ];

  void _generate() {
    if (_generating) return;
    setState(() {
      _generating = true;
      _status = 'Generating...';
      _progress = 0.08;
      if (_credits > 0) _credits -= 5;
    });
    // Simulate streaming progress.
    _tick(0);
  }

  void _tick(int step) {
    if (!mounted) return;
    final steps = [
      (0.30, 'Reading input...'),
      (0.55, 'Making Note...'),
      (0.78, 'Summarizing...'),
      (0.94, 'Polishing...'),
      (1.0, 'Done'),
    ];
    if (step >= steps.length) {
      setState(() => _generating = false);
      return;
    }
    Future.delayed(Duration(milliseconds: 700 + step * 120), () {
      if (!mounted) return;
      setState(() {
        _progress = steps[step].$1;
        _status = steps[step].$2;
      });
      _tick(step + 1);
    });
  }

  @override
  void dispose() {
    _promptCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _header(),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
                  children: [
                    const SizedBox(height: 8),
                    FadeSlideIn(index: 0, child: _searchRow()),
                    const SizedBox(height: 20),
                    FadeSlideIn(index: 1, child: _categoryRow()),
                    const SizedBox(height: 26),
                    FadeSlideIn(index: 2, child: _generationPanel()),
                    const SizedBox(height: 22),
                    FadeSlideIn(index: 3, child: _creditsCard()),
                    const SizedBox(height: 16),
                    FadeSlideIn(
                      index: 4,
                      child: GradientButton(
                        label: _generating ? 'Generating…' : 'Generate',
                        icon: Icons.auto_awesome,
                        enabled: !_generating,
                        onPressed: _generate,
                      ),
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

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          GlassIconButton(
            icon: Icons.chevron_left,
            onTap: () {},
          ),
          const Spacer(),
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.glass,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: const Text(
                  'Your request',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),
          GlassIconButton(
            icon: Icons.notifications_none,
            badge: true,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _searchRow() {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.glass,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search,
                        size: 20, color: AppColors.textMuted),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                        decoration: const InputDecoration(
                          isCollapsed: true,
                          border: InputBorder.none,
                          hintText: 'Search',
                          hintStyle: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            color: AppColors.textMuted,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        GlassIconButton(
          icon: Icons.qr_code_scanner,
          size: 52,
          onTap: () {},
        ),
      ],
    );
  }

  /// Clean, framed generation section: a labelled header row, the gold dial
  /// on a soft pedestal, and a live status caption.
  /// True while a generation is mid-flight (running, or paused part-way).
  bool get _active =>
      _generating || (_progress > 0.001 && _progress < 0.999);

  Widget _generationPanel() {
    final eta = _active
        ? '~${((1 - _progress) * 14).ceil()}s remaining'
        : 'Ready to generate';
    return Column(
      children: [
        Row(
          children: [
            Text(
              'Workspace',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w700,
                fontSize: 13,
                letterSpacing: 1.6,
                color: Colors.white.withValues(alpha: 0.55),
              ),
            ),
            const Spacer(),
            _statusChip(),
          ],
        ),
        const SizedBox(height: 18),
        // Dial on a faint radial pedestal.
        SizedBox(
          height: 230,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 230,
                height: 230,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.gold.withValues(alpha: 0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              ProgressRing(progress: _progress, label: _status),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          eta,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.w500,
            fontSize: 13,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _statusChip() {
    final active = _active;
    final color = active ? AppColors.gold : AppColors.accentCyan;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PulseDot(color: color),
          const SizedBox(width: 7),
          Text(
            active ? 'Generating' : 'Idle',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryRow() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final c = _categories[i];
          return CategoryChip(
            label: c.label,
            icon: c.icon,
            selected: _category == i,
            onTap: () => setState(() => _category = i),
          );
        },
      ),
    );
  }

  Widget _creditsCard() {
    return GlassCard(
      radius: 24,
      padding: const EdgeInsets.all(16),
      color: AppColors.glassStrong,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShaderMask(
                shaderCallback: (r) => AppGradients.accent.createShader(r),
                child: const Icon(Icons.bolt, size: 18, color: Colors.white),
              ),
              const SizedBox(width: 6),
              Text(
                '$_credits',
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 5),
              const Text(
                'Credits Remaining',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Pressable(
                onTap: () => setState(() => _credits += 100),
                child: ShaderMask(
                  shaderCallback: (r) => AppGradients.accent.createShader(r),
                  child: const Text(
                    'Update',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _promptCtrl,
                    minLines: 1,
                    maxLines: 3,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 15,
                      color: Color(0xFF1A1A24),
                    ),
                    decoration: const InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: 'Describe your project…',
                      hintStyle: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        color: Color(0xFF8A8A99),
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Pressable(
                  onTap: _generate,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppGradients.accent,
                    ),
                    child: const Icon(Icons.arrow_upward,
                        size: 20, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _miniTool(Icons.mic_none),
              const SizedBox(width: 10),
              _miniTool(Icons.attach_file),
              const SizedBox(width: 10),
              _miniTool(Icons.image_outlined),
              const Spacer(),
              Pressable(
                onTap: widget.onOpenSettings,
                child: const Icon(Icons.tune,
                    size: 20, color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniTool(IconData icon) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.glass,
        border: Border.all(color: AppColors.glassBorderSoft),
      ),
      child: Icon(icon, size: 17, color: AppColors.textSecondary),
    );
  }
}

/// A small breathing status dot.
class _PulseDot extends StatefulWidget {
  const _PulseDot({required this.color});
  final Color color;

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = _c.value;
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color,
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.3 + 0.5 * t),
                blurRadius: 4 + 6 * t,
                spreadRadius: t,
              ),
            ],
          ),
        );
      },
    );
  }
}
