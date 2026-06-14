import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_settings.dart';
import 'intro_page.dart';
import 'task.dart';
import 'todo_theme.dart';

/// The Settings tab — pick a cute accent (recolors the app live), peek at your
/// progress, manage tasks, and replay the intro. Sections rise in on entry.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  )..forward();

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  void _replayIntro() {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, _, _) =>
            IntroPage(onDone: () => Navigator.of(context).pop()),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: T.ink,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Text(
            message,
            style: const TextStyle(
                fontFamily: T.font, fontWeight: FontWeight.w600),
          ),
        ),
      );
  }

  void _clearDone() {
    HapticFeedback.lightImpact();
    taskStore.clearDone();
    _toast('Cleared completed tasks ✨');
  }

  Future<void> _clearAll() async {
    HapticFeedback.lightImpact();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: T.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Clear all tasks?',
            style: TextStyle(fontFamily: T.fontDisplay, fontWeight: FontWeight.w800)),
        content: const Text('This removes every task. It can’t be undone.',
            style: TextStyle(fontFamily: T.font, color: T.inkSoft)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(fontFamily: T.font, color: T.inkSoft, fontWeight: FontWeight.w700)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Clear all',
                style: TextStyle(fontFamily: T.font, color: T.accentDeep, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
    if (ok == true) {
      taskStore.clearAll();
      _toast('All tasks cleared 🧹');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: T.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            _rise(0, const _Header()),
            const SizedBox(height: 20),
            _rise(1, const _StatsCard()),
            const SizedBox(height: 24),
            _rise(2, const _SectionLabel('Accent colour')),
            const SizedBox(height: 10),
            _rise(3, const _AccentPicker()),
            const SizedBox(height: 24),
            _rise(4, const _SectionLabel('Tasks')),
            const SizedBox(height: 10),
            _rise(
              5,
              _Card(children: [
                _ActionRow(
                  icon: Icons.cleaning_services_rounded,
                  title: 'Clear completed',
                  subtitle: 'Remove tasks you’ve finished',
                  onTap: _clearDone,
                ),
                const _Divider(),
                _ActionRow(
                  icon: Icons.delete_sweep_rounded,
                  title: 'Clear all tasks',
                  subtitle: 'Start with a clean slate',
                  onTap: _clearAll,
                ),
              ]),
            ),
            const SizedBox(height: 24),
            _rise(6, const _SectionLabel('About')),
            const SizedBox(height: 10),
            _rise(
              7,
              _Card(children: [
                _ActionRow(
                  icon: Icons.replay_rounded,
                  title: 'Replay intro',
                  subtitle: 'Watch the welcome tour again',
                  onTap: _replayIntro,
                ),
                const _Divider(),
                const _AboutRow(),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  /// Staggered fade + slide-up entrance keyed to section order.
  Widget _rise(int order, Widget child) {
    final start = (order * 0.07).clamp(0.0, 0.7);
    final anim = CurvedAnimation(
      parent: _intro,
      curve: Interval(start, (start + 0.4).clamp(0.0, 1.0),
          curve: Curves.easeOutCubic),
    );
    return AnimatedBuilder(
      animation: anim,
      builder: (_, child) => Opacity(
        opacity: anim.value,
        child: Transform.translate(
            offset: Offset(0, 18 * (1 - anim.value)), child: child),
      ),
      child: child,
    );
  }
}

// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Make it yours',
                  style: TextStyle(
                      fontFamily: T.font,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: T.inkSoft)),
              SizedBox(height: 2),
              Text('Settings',
                  style: TextStyle(
                      fontFamily: T.fontDisplay,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      color: T.ink)),
            ],
          ),
        ),
        // Gently bobbing 3D mascot.
        _Bob(child: Image.asset(T.emoji('starstruck'), width: 56, height: 56)),
      ],
    );
  }
}

/// Live stats: streak + completed + total, recoloured with the accent.
class _StatsCard extends StatelessWidget {
  const _StatsCard();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: taskStore,
      builder: (context, _) {
        final done = taskStore.completed;
        final total = taskStore.total;
        final streak = taskStore.streak;
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [T.accent, T.accentDeep],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                  color: T.accent.withAlpha(70),
                  blurRadius: 24,
                  offset: const Offset(0, 10)),
            ],
          ),
          child: Row(
            children: [
              _Stat(value: '$streak', label: 'day streak', emoji: 'fire'),
              _StatDivider(),
              _Stat(value: '$done', label: 'completed', emoji: 'check'),
              _StatDivider(),
              _Stat(value: '$total', label: 'total', emoji: 'notepad'),
            ],
          ),
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, required this.emoji});
  final String value;
  final String label;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Image.asset(T.emoji(emoji), width: 30, height: 30),
          const SizedBox(height: 8),
          // Count-up feel: the number pops when it changes.
          TweenAnimationBuilder<double>(
            key: ValueKey(value),
            tween: Tween(begin: 0.6, end: 1),
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutBack,
            builder: (_, s, child) => Transform.scale(scale: s, child: child),
            child: Text(value,
                style: const TextStyle(
                    fontFamily: T.fontDisplay,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white)),
          ),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  fontFamily: T.font,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withAlpha(220))),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 44, color: Colors.white.withAlpha(46));
  }
}

/// Row of cute accent swatches; tapping recolors the whole app live.
class _AccentPicker extends StatelessWidget {
  const _AccentPicker();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appSettings,
      builder: (context, _) {
        return _Card(
          children: [
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                for (final c in T.accentChoices)
                  _Swatch(
                    color: c,
                    selected: c.toARGB32() == appSettings.accent.toARGB32(),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      appSettings.setAccent(c);
                    },
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch(
      {required this.color, required this.selected, required this.onTap});
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: color.withAlpha(selected ? 130 : 60),
                blurRadius: selected ? 16 : 8,
                offset: const Offset(0, 4)),
          ],
          border: Border.all(
            color: selected ? Colors.white : Colors.transparent,
            width: 3,
          ),
        ),
        child: AnimatedScale(
          scale: selected ? 1 : 0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutBack,
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable bits
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontFamily: T.font,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: T.inkSoft,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: T.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: T.cardShadow,
      ),
      child: Column(children: children),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Divider(height: 1, color: T.ink.withAlpha(12)),
      );
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: T.accentWash,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: T.accentDeep, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontFamily: T.font,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: T.ink)),
                  const SizedBox(height: 1),
                  Text(subtitle,
                      style: const TextStyle(
                          fontFamily: T.font,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: T.inkSoft)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: T.inkFaint),
          ],
        ),
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  const _AboutRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: T.accentWash,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Image.asset(T.emoji('heart'), width: 24, height: 24),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Little Tasks',
                    style: TextStyle(
                        fontFamily: T.font,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: T.ink)),
                SizedBox(height: 1),
                Text('v1.0 · made with love & 3D emoji',
                    style: TextStyle(
                        fontFamily: T.font,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: T.inkSoft)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Continuously bobbing wrapper.
class _Bob extends StatefulWidget {
  const _Bob({required this.child});
  final Widget child;

  @override
  State<_Bob> createState() => _BobState();
}

class _BobState extends State<_Bob> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) {
        final v = (_c.value * 2 - 1).abs(); // 1->0->1 triangle
        return Transform.translate(offset: Offset(0, -6 * (1 - v)), child: child);
      },
      child: widget.child,
    );
  }
}
