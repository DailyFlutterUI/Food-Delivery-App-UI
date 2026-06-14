import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'add_deposit_sheet.dart';
import 'coin_rain.dart';
import 'edit_goal_sheet.dart';
import 'golden_burst.dart';
import 'savings_jar.dart';
import 'savings_store.dart';
import 'savings_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final _store = savingsStore;

  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    _store.addListener(_onChanged);
    if (_store.loaded) {
      _intro.forward();
    } else {
      _store.load().then((_) => _intro.forward());
    }
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _store.removeListener(_onChanged);
    _intro.dispose();
    super.dispose();
  }

  void _openAdd() {
    AddDepositSheet.show(context, onSubmit: _deposit);
  }

  void _deposit(double amount) {
    final crossed = _store.deposit(amount);
    HapticFeedback.mediumImpact();
    // Bigger saves rain harder; relative to the target so it always feels right.
    final intensity = (amount / (_store.target * 0.2)).clamp(0.25, 1.0);
    CoinRain.play(context, intensity: intensity);

    if (crossed.isNotEmpty) {
      // Celebrate the highest milestone this save unlocked.
      final m = crossed.last;
      Future.delayed(const Duration(milliseconds: 520), () {
        if (!mounted) return;
        HapticFeedback.heavyImpact();
        final reachedGoal = m >= 1.0;
        GoldenBurst.play(
          context,
          title: reachedGoal ? 'Goal reached! 🎉' : '${(m * 100).round()}% there',
          subtitle: reachedGoal
              ? 'You saved ${S.money(_store.target)} for ${_store.goalName}'
              : 'Keep the rain coming',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_store.loaded) {
      return Scaffold(
        backgroundColor: S.bg,
        body: Center(
          child: CircularProgressIndicator(color: S.accent, strokeWidth: 3),
        ),
      );
    }

    return Scaffold(
      backgroundColor: S.bg,
      body: Stack(
        children: [
          const _AmbientGlow(),
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _header()),
                SliverToBoxAdapter(child: _jarSection()),
                SliverToBoxAdapter(child: _statsRow()),
                SliverToBoxAdapter(child: _milestoneTrack()),
                SliverToBoxAdapter(child: _activityHeader()),
                if (_store.deposits.isEmpty)
                  const SliverToBoxAdapter(child: _EmptyActivity())
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 140),
                    sliver: SliverList.builder(
                      itemCount: math.min(_store.deposits.length, 12),
                      itemBuilder: (_, i) => _DepositRow(
                        deposit: _store.deposits[i],
                        index: i,
                        controller: _intro,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _RainButton(onTap: _openAdd),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "You're saving for",
                  style: TextStyle(
                    fontFamily: S.font,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: S.inkSoft,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _store.goalName,
                  style: const TextStyle(
                    fontFamily: S.fontDisplay,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: S.ink,
                  ),
                ),
              ],
            ),
          ),
          _IconChip(
            icon: Icons.tune_rounded,
            onTap: () => EditGoalSheet.show(context),
          ),
        ],
      ),
    );
  }

  Widget _jarSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
      child: Center(
        child: SavingsJar(
          progress: _store.progress,
          centerLabel: S.money(_store.balance),
          centerSub: 'of ${S.money(_store.target)}',
        ),
      ),
    );
  }

  Widget _statsRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 4),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: S.card,
          borderRadius: BorderRadius.circular(24),
          boxShadow: S.cardShadow,
        ),
        child: Row(
          children: [
            _Stat(
              label: 'Saved',
              value: S.money(_store.balance),
              tint: S.goldDeep,
            ),
            _Divider(),
            _Stat(
              label: 'To go',
              value: S.money(_store.remaining),
              tint: S.ink,
            ),
            _Divider(),
            _Stat(
              label: 'Deposits',
              value: '${_store.depositCount}',
              tint: S.accentDeep,
            ),
          ],
        ),
      ),
    );
  }

  Widget _milestoneTrack() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        children: [
          for (final m in kMilestones) ...[
            Expanded(
              child: _MilestonePip(
                fraction: m,
                done: _store.progress >= m,
              ),
            ),
            if (m != kMilestones.last) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Widget _activityHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(22, 26, 22, 12),
      child: Text(
        'Recent rain',
        style: TextStyle(
          fontFamily: S.fontDisplay,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: S.ink,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pieces
// ---------------------------------------------------------------------------

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Positioned(
      top: -size.width * 0.35,
      left: size.width * 0.1,
      child: Container(
        width: size.width * 0.8,
        height: size.width * 0.8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [S.accentHalo, S.accent.withAlpha(0)],
          ),
        ),
      ),
    );
  }
}

class _IconChip extends StatelessWidget {
  const _IconChip({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: S.card,
          shape: BoxShape.circle,
          boxShadow: S.cardShadow,
        ),
        child: Icon(icon, size: 22, color: S.inkSoft),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.tint});
  final String label;
  final String value;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: S.fontDisplay,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              color: tint,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              fontFamily: S.font,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: S.inkSoft,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 34,
      color: S.inkFaint.withValues(alpha: 0.35),
    );
  }
}

/// A milestone marker on the track — a small minted pip that goes gold when hit.
class _MilestonePip extends StatelessWidget {
  const _MilestonePip({required this.fraction, required this.done});
  final double fraction;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          height: 8,
          decoration: BoxDecoration(
            gradient: done
                ? const LinearGradient(colors: [S.goldLight, S.gold])
                : null,
            color: done ? null : S.inkFaint.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
            boxShadow: done ? S.goldShadowSoft : null,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${(fraction * 100).round()}%',
          style: TextStyle(
            fontFamily: S.font,
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: done ? S.goldDeep : S.inkFaint,
          ),
        ),
      ],
    );
  }
}

class _DepositRow extends StatelessWidget {
  const _DepositRow({
    required this.deposit,
    required this.index,
    required this.controller,
  });

  final Deposit deposit;
  final int index;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    final start = (index * 0.06).clamp(0.0, 0.6);
    final anim = CurvedAnimation(
      parent: controller,
      curve: Interval(start, (start + 0.4).clamp(0.0, 1.0),
          curve: Curves.easeOutCubic),
    );
    return AnimatedBuilder(
      animation: anim,
      builder: (_, child) => Opacity(
        opacity: anim.value,
        child: Transform.translate(
          offset: Offset(0, 14 * (1 - anim.value)),
          child: child,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: S.card,
          borderRadius: BorderRadius.circular(18),
          boxShadow: S.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [S.goldLight, S.gold, S.goldDeep],
                ),
                shape: BoxShape.circle,
                boxShadow: S.goldShadowSoft,
              ),
              alignment: Alignment.center,
              child: const Text(
                r'$',
                style: TextStyle(
                  fontFamily: S.fontDisplay,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Saved ${S.money(deposit.amount)}',
                    style: const TextStyle(
                      fontFamily: S.fontDisplay,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: S.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _relative(deposit.at),
                    style: const TextStyle(
                      fontFamily: S.font,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: S.inkSoft,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '+${S.money(deposit.amount)}',
              style: const TextStyle(
                fontFamily: S.fontDisplay,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: S.goldDeep,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _relative(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'Just now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    if (d.inDays < 7) return '${d.inDays}d ago';
    return '${t.day}/${t.month}/${t.year}';
  }
}

class _EmptyActivity extends StatelessWidget {
  const _EmptyActivity();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 4, 20, 140),
      child: Center(
        child: Text(
          'No drops yet — tap below to make it rain ☔️',
          style: TextStyle(
            fontFamily: S.font,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: S.inkSoft,
          ),
        ),
      ),
    );
  }
}

/// The primary action — a wide pill that gently pulses its gold glow.
class _RainButton extends StatefulWidget {
  const _RainButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_RainButton> createState() => _RainButtonState();
}

class _RainButtonState extends State<_RainButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1700),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTap();
        },
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, child) {
            final glow = 16 + _c.value * 12;
            return Container(
              height: 60,
              decoration: BoxDecoration(
                color: S.accent,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: S.accentGlow,
                    blurRadius: glow,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: child,
            );
          },
          child: const Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, color: Colors.white, size: 24),
                SizedBox(width: 8),
                Text(
                  'Save money',
                  style: TextStyle(
                    fontFamily: S.fontDisplay,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
