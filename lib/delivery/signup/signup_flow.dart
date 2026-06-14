import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../track_screen.dart';
import 'signup_data.dart';
import 'signup_theme.dart';
import 'world_map.dart';

/// Standalone entry for the **Global Shipping Signup** — a premium onboarding
/// that ends with the world zooming into the user's country, then hands off to
/// the live tracking screen.
class GlobalSignupApp extends StatelessWidget {
  const GlobalSignupApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parcel — Sign up',
      debugShowCheckedModeBanner: false,
      theme: S.theme,
      home: const SignupFlow(),
    );
  }
}

enum _Step { country, phone, region, launch }

class SignupFlow extends StatefulWidget {
  const SignupFlow({super.key});

  @override
  State<SignupFlow> createState() => _SignupFlowState();
}

class _SignupFlowState extends State<SignupFlow> {
  _Step _step = _Step.country;

  Country? _country;
  Region? _region;

  void _go(_Step to) {
    HapticFeedback.selectionClick();
    setState(() => _step = to);
  }

  void _finish() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const TrackScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final overlay = SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: S.bg,
    );

    // The launch step is full-bleed (no chrome) so the planet fills the screen.
    if (_step == _Step.launch) {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: overlay,
        child: LaunchStep(
          country: _country!,
          region: _region!,
          onStart: _finish,
        ),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: Scaffold(
        backgroundColor: S.bg,
        body: Stack(
          children: [
            const Positioned.fill(child: _Backdrop()),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    _Header(
                      step: _step,
                      onBack: _step == _Step.country
                          ? null
                          : () => _go(_Step.values[_step.index - 1]),
                    ),
                    const SizedBox(height: 22),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 460),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween(
                              begin: const Offset(0.06, 0),
                              end: Offset.zero,
                            ).animate(anim),
                            child: child,
                          ),
                        ),
                        child: _body(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    switch (_step) {
      case _Step.country:
        return CountryStep(
          key: const ValueKey('country'),
          selected: _country,
          onSelected: (c) => setState(() {
            _country = c;
            _region = null;
          }),
          onNext: () => _go(_Step.phone),
        );
      case _Step.phone:
        return PhoneStep(
          key: const ValueKey('phone'),
          country: _country!,
          onVerified: (_) => _go(_Step.region),
        );
      case _Step.region:
        return RegionStep(
          key: const ValueKey('region'),
          country: _country!,
          selected: _region,
          onSelected: (r) => setState(() => _region = r),
          onNext: () => _go(_Step.launch),
        );
      case _Step.launch:
        return const SizedBox.shrink();
    }
  }
}

// ===========================================================================
// Backdrop — rich near-black with a quiet accent aurora up top
// ===========================================================================

class _Backdrop extends StatelessWidget {
  const _Backdrop();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [S.bgLow, S.bg],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -180,
            left: -60,
            right: -60,
            height: 420,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [S.accentA(0.14), S.accentA(0)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// Header — frosted back button + refined progress
// ===========================================================================

class _Header extends StatelessWidget {
  const _Header({required this.step, required this.onBack});

  final _Step step;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    const total = 3;
    return Row(
      children: [
        _GlassCircle(
          icon: Icons.arrow_back_ios_new_rounded,
          enabled: onBack != null,
          onTap: onBack,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Row(
            children: [
              for (int i = 0; i < total; i++) ...[
                Expanded(child: _Segment(active: i <= step.index)),
                if (i != total - 1) const SizedBox(width: 7),
              ],
            ],
          ),
        ),
        const SizedBox(width: 16),
        Text(
          '${step.index + 1} / $total',
          style: const TextStyle(
            fontFamily: S.font,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
            color: S.inkMute,
          ),
        ),
      ],
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: active ? 1 : 0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (_, v, _) => ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: Stack(
          children: [
            Container(height: 5, color: S.hair),
            FractionallySizedBox(
              widthFactor: v,
              child: Container(
                height: 5,
                decoration: const BoxDecoration(color: S.accent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassCircle extends StatelessWidget {
  const _GlassCircle({
    required this.icon,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: enabled ? 1 : 0,
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: ClipOval(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: S.surfaceHi.withValues(alpha: 0.7),
                shape: BoxShape.circle,
                border: Border.all(color: S.hair),
              ),
              child: Icon(icon, size: 16, color: S.ink),
            ),
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// Shared bits
// ===========================================================================

class _Intro extends StatelessWidget {
  const _Intro({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });
  final String eyebrow;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(eyebrow.toUpperCase(), style: S.eyebrow),
        const SizedBox(height: 10),
        Text(title, style: S.title),
        const SizedBox(height: 9),
        Text(subtitle, style: S.subtitle),
      ],
    );
  }
}

class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.enabled = true,
    this.icon,
  });

  final String label;
  final VoidCallback onTap;
  final bool enabled;
  final IconData? icon;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final on = widget.enabled;
    return GestureDetector(
      onTapDown: on ? (_) => setState(() => _down = true) : null,
      onTapUp: on ? (_) => setState(() => _down = false) : null,
      onTapCancel: on ? () => setState(() => _down = false) : null,
      onTap: on
          ? () {
              HapticFeedback.mediumImpact();
              widget.onTap();
            }
          : null,
      child: AnimatedScale(
        scale: _down ? 0.97 : 1,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on ? S.accent : S.surface,
            borderRadius: BorderRadius.circular(20),
            border: on ? null : Border.all(color: S.hair),
            boxShadow: on ? S.accentGlow : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  fontFamily: S.font,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                  color: on ? Colors.white : S.inkFaint,
                ),
              ),
              if (widget.icon != null) ...[
                const SizedBox(width: 9),
                Icon(widget.icon,
                    size: 19, color: on ? Colors.white : S.inkFaint),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Wraps a tappable surface with a subtle press-in scale so every card feels
/// tactile and responsive — premium polish without extra chrome.
class _Pressable extends StatefulWidget {
  const _Pressable({required this.onTap, required this.child});
  final VoidCallback onTap;
  final Widget child;

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.98 : 1,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

// ===========================================================================
// Step 1 — Choose country
// ===========================================================================

class CountryStep extends StatefulWidget {
  const CountryStep({
    super.key,
    required this.selected,
    required this.onSelected,
    required this.onNext,
  });

  final Country? selected;
  final ValueChanged<Country> onSelected;
  final VoidCallback onNext;

  @override
  State<CountryStep> createState() => _CountryStepState();
}

class _CountryStepState extends State<CountryStep> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final list = q.isEmpty
        ? kCountries
        : kCountries
            .where((c) =>
                c.name.toLowerCase().contains(q) || c.dial.contains(q))
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Intro(
          eyebrow: 'Get started',
          title: 'Where are you\nshipping from?',
          subtitle: 'Pick your country to set up global delivery.',
        ),
        const SizedBox(height: 22),
        _SearchField(onChanged: (v) => setState(() => _query = v)),
        const SizedBox(height: 16),
        Expanded(
          child: ShaderMask(
            shaderCallback: (rect) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Colors.white, Colors.transparent],
              stops: [0, 0.93, 1],
            ).createShader(rect),
            blendMode: BlendMode.dstIn,
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: 16),
              physics: const BouncingScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final c = list[i];
                return _CountryTile(
                  country: c,
                  selected: c.iso == widget.selected?.iso,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    widget.onSelected(c);
                  },
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 6),
        PrimaryButton(
          label: 'Continue',
          icon: Icons.arrow_forward_rounded,
          enabled: widget.selected != null,
          onTap: widget.onNext,
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: S.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: S.hair),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, size: 20, color: S.inkMute),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              style: const TextStyle(
                fontFamily: S.font,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: S.ink,
              ),
              cursorColor: S.accent,
              decoration: const InputDecoration(
                isCollapsed: true,
                contentPadding: EdgeInsets.symmetric(vertical: 17),
                border: InputBorder.none,
                hintText: 'Search 18 countries',
                hintStyle: TextStyle(
                  fontFamily: S.font,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: S.inkFaint,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountryTile extends StatelessWidget {
  const _CountryTile({
    required this.country,
    required this.selected,
    required this.onTap,
  });

  final Country country;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color.lerp(S.surface, S.accentA(0.10), selected ? 1 : 0),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Color.lerp(S.hair, S.accent, selected ? 1 : 0)!,
            width: 1.4,
          ),
        ),
        child: Row(
          children: [
            _FlagChip(flag: country.flag, active: selected),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    country.name,
                    style: const TextStyle(
                      fontFamily: S.font,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                      color: S.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${country.dial} · ${country.regions.length} regions',
                    style: const TextStyle(
                      fontFamily: S.font,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: S.inkMute,
                    ),
                  ),
                ],
              ),
            ),
            _Check(selected: selected),
          ],
        ),
      ),
    );
  }
}

class _FlagChip extends StatelessWidget {
  const _FlagChip({required this.flag, required this.active});
  final String flag;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      width: 46,
      height: 46,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: S.surfaceHi,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: active ? S.accentA(0.5) : S.hair),
      ),
      child: Text(flag, style: const TextStyle(fontSize: 24)),
    );
  }
}

class _Check extends StatelessWidget {
  const _Check({required this.selected});
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: selected ? 1 : 0.6,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutBack,
      child: AnimatedOpacity(
        opacity: selected ? 1 : 0,
        duration: const Duration(milliseconds: 180),
        child: Container(
          width: 26,
          height: 26,
          margin: const EdgeInsets.only(right: 4),
          decoration: const BoxDecoration(
            color: S.accent,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
        ),
      ),
    );
  }
}

// ===========================================================================
// Step 2 — Phone verification (self-contained keypad, no OS keyboard needed)
// ===========================================================================

class PhoneStep extends StatefulWidget {
  const PhoneStep({
    super.key,
    required this.country,
    required this.onVerified,
  });

  final Country country;
  final ValueChanged<String> onVerified;

  @override
  State<PhoneStep> createState() => _PhoneStepState();
}

enum _PhonePhase { number, sending, code, verifying, done }

class _PhoneStepState extends State<PhoneStep> {
  _PhonePhase _phase = _PhonePhase.number;
  String _number = '';
  String _code = '';

  static const _maxDigits = 10;
  static const _codeLen = 5;

  String get _fullNumber => '${widget.country.dial} ${_grouped(_number)}';

  void _onKey(String k) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_phase == _PhonePhase.number) {
        if (k == '<') {
          if (_number.isNotEmpty) {
            _number = _number.substring(0, _number.length - 1);
          }
        } else if (_number.length < _maxDigits) {
          _number += k;
        }
      } else if (_phase == _PhonePhase.code) {
        if (k == '<') {
          if (_code.isNotEmpty) _code = _code.substring(0, _code.length - 1);
        } else if (_code.length < _codeLen) {
          _code += k;
          if (_code.length == _codeLen) _verify();
        }
      }
    });
  }

  Future<void> _sendCode() async {
    HapticFeedback.mediumImpact();
    setState(() => _phase = _PhonePhase.sending);
    await Future.delayed(const Duration(milliseconds: 1900));
    if (!mounted) return;
    HapticFeedback.lightImpact();
    setState(() => _phase = _PhonePhase.code);
  }

  Future<void> _verify() async {
    setState(() => _phase = _PhonePhase.verifying);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    HapticFeedback.heavyImpact();
    setState(() => _phase = _PhonePhase.done);
    await Future.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;
    widget.onVerified(_fullNumber);
  }

  @override
  Widget build(BuildContext context) {
    final p = _phase;

    // Sending + done take over the whole step with centered moments.
    if (p == _PhonePhase.sending) {
      return _CenterMoment(
        loader: _OrbitLoader(child: Text(widget.country.flag,
            style: const TextStyle(fontSize: 34))),
        title: 'Sending your code',
        subtitle: 'Texting a 5-digit code to\n$_fullNumber',
      );
    }
    if (p == _PhonePhase.done) {
      return _CenterMoment(
        loader: const _SuccessMark(),
        title: 'You’re verified',
        subtitle: 'Number confirmed — setting up your\nshipping regions…',
      );
    }

    final onNumber = p == _PhonePhase.number;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Intro(
          eyebrow: onNumber ? 'Verify it’s you' : 'Check your messages',
          title: onNumber ? 'Your phone\nnumber' : 'Enter the\n5-digit code',
          subtitle: onNumber
              ? 'We’ll send a one-time code by SMS.'
              : 'Sent to $_fullNumber',
        ),
        const SizedBox(height: 26),
        if (onNumber)
          _NumberField(country: widget.country, number: _number)
        else
          _CodeBoxes(
            code: _code,
            length: _codeLen,
            verifying: p == _PhonePhase.verifying,
          ),
        if (!onNumber) ...[
          const SizedBox(height: 18),
          Center(child: _CodeStatusLine(verifying: p == _PhonePhase.verifying)),
        ],
        const Spacer(),
        if (onNumber)
          PrimaryButton(
            label: 'Send code',
            icon: Icons.arrow_forward_rounded,
            enabled: _number.length >= 7,
            onTap: _sendCode,
          )
        else
          const SizedBox(height: 60),
        const SizedBox(height: 18),
        _Keypad(onKey: _onKey),
        const SizedBox(height: 8),
      ],
    );
  }

  static String _grouped(String n) {
    final b = StringBuffer();
    for (int i = 0; i < n.length; i++) {
      if (i == 3 || i == 6) b.write(' ');
      b.write(n[i]);
    }
    return b.toString();
  }
}

/// A centered full-step moment (sending / verified) — loader + copy.
class _CenterMoment extends StatelessWidget {
  const _CenterMoment({
    required this.loader,
    required this.title,
    required this.subtitle,
  });

  final Widget loader;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          loader,
          const SizedBox(height: 30),
          Text(
            title,
            style: const TextStyle(
              fontFamily: S.font,
              fontSize: 21,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: S.ink,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: S.font,
              fontSize: 14,
              height: 1.45,
              fontWeight: FontWeight.w500,
              color: S.inkMute,
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({required this.country, required this.number});
  final Country country;
  final String number;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: S.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: number.isEmpty ? S.hair : S.accentA(0.55)),
      ),
      child: Row(
        children: [
          Text(country.flag, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Text(
            country.dial,
            style: const TextStyle(
              fontFamily: S.font,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: S.ink,
            ),
          ),
          Container(
            width: 1,
            height: 26,
            margin: const EdgeInsets.symmetric(horizontal: 14),
            color: S.hair,
          ),
          // Digits + a caret that sits immediately after the last one, so it
          // tracks the typing position instead of floating at the field edge.
          Expanded(
            child: Row(
              children: [
                if (number.isEmpty) ...[
                  const _Caret(),
                  const SizedBox(width: 6),
                  const Text(
                    'Phone number',
                    style: TextStyle(
                      fontFamily: S.font,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: S.inkFaint,
                    ),
                  ),
                ] else ...[
                  Flexible(
                    child: Text(
                      _PhoneStepState._grouped(number),
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      softWrap: false,
                      style: const TextStyle(
                        fontFamily: S.font,
                        fontSize: 18,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w700,
                        color: S.ink,
                      ),
                    ),
                  ),
                  const SizedBox(width: 3),
                  const _Caret(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Caret extends StatefulWidget {
  const _Caret();
  @override
  State<_Caret> createState() => _CaretState();
}

class _CaretState extends State<_Caret> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _c,
      child: Container(
        width: 2.5,
        height: 26,
        decoration: BoxDecoration(
          color: S.accent,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _CodeBoxes extends StatelessWidget {
  const _CodeBoxes({
    required this.code,
    required this.length,
    required this.verifying,
  });

  final String code;
  final int length;
  final bool verifying;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (int i = 0; i < length; i++)
          _CodeBox(
            char: i < code.length ? code[i] : '',
            active: i == code.length && !verifying,
          ),
      ],
    );
  }
}

class _CodeBox extends StatelessWidget {
  const _CodeBox({required this.char, required this.active});

  final String char;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final filled = char.isNotEmpty;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      width: 56,
      height: 66,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: S.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: active
              ? S.accent
              : filled
                  ? S.accentA(0.5)
                  : S.hair,
          width: active || filled ? 1.6 : 1,
        ),
      ),
      child: AnimatedScale(
        scale: filled ? 1 : 0.4,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        child: Text(
          char,
          style: const TextStyle(
            fontFamily: S.font,
            fontSize: 25,
            fontWeight: FontWeight.w800,
            color: S.ink,
          ),
        ),
      ),
    );
  }
}

class _CodeStatusLine extends StatelessWidget {
  const _CodeStatusLine({required this.verifying});
  final bool verifying;

  @override
  Widget build(BuildContext context) {
    if (verifying) {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Dots(),
          SizedBox(width: 10),
          Text(
            'Verifying',
            style: TextStyle(
              fontFamily: S.font,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: S.inkMute,
            ),
          ),
        ],
      );
    }
    return Text.rich(
      TextSpan(
        text: 'Didn’t get it?  ',
        style: const TextStyle(
          fontFamily: S.font,
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
          color: S.inkMute,
        ),
        children: [
          TextSpan(
            text: 'Resend in 0:28',
            style: TextStyle(
              fontFamily: S.font,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: S.accentHi,
            ),
          ),
        ],
      ),
    );
  }
}

/// Three softly pulsing accent dots — a calmer loader than a spinner.
class _Dots extends StatefulWidget {
  const _Dots();
  @override
  State<_Dots> createState() => _DotsState();
}

class _DotsState extends State<_Dots> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
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
      builder: (_, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < 3; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Transform.translate(
                offset: Offset(
                    0, -3 * math.sin((_c.value + i * 0.18) * 2 * math.pi)),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: S.accent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Big sending loader: dual orbiting arcs around the centered child.
class _OrbitLoader extends StatefulWidget {
  const _OrbitLoader({required this.child});
  final Widget child;

  @override
  State<_OrbitLoader> createState() => _OrbitLoaderState();
}

class _OrbitLoaderState extends State<_OrbitLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
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
      builder: (_, child) => SizedBox(
        width: 116,
        height: 116,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size(116, 116),
              painter: _OrbitPainter(_c.value),
            ),
            child!,
          ],
        ),
      ),
      child: Container(
        width: 82,
        height: 82,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: S.surface,
          shape: BoxShape.circle,
          border: Border.all(color: S.hair),
          boxShadow: S.soft,
        ),
        child: widget.child,
      ),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  _OrbitPainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 3;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = S.hair,
    );
    void arc(double start, double sweep, double op) {
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        start,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..color = S.accent.withValues(alpha: op),
      );
    }

    final a = t * 2 * math.pi;
    arc(a, 1.5, 1.0);
    arc(a + math.pi, 1.0, 0.5);
  }

  @override
  bool shouldRepaint(_OrbitPainter old) => old.t != t;
}

/// The verified success mark — an accent disc with a check that scales in
/// behind a soft expanding ring.
class _SuccessMark extends StatefulWidget {
  const _SuccessMark();
  @override
  State<_SuccessMark> createState() => _SuccessMarkState();
}

class _SuccessMarkState extends State<_SuccessMark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) {
        final pop = Curves.easeOutBack.transform(_c.value.clamp(0.0, 1.0));
        final ring = Curves.easeOut.transform(_c.value);
        return SizedBox(
          width: 116,
          height: 116,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // expanding ring
              Container(
                width: 60 + ring * 56,
                height: 60 + ring * 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: S.accentA((1 - ring) * 0.6),
                    width: 2,
                  ),
                ),
              ),
              Transform.scale(
                scale: pop,
                child: Container(
                  width: 82,
                  height: 82,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: S.accent,
                    shape: BoxShape.circle,
                    boxShadow: S.accentGlow,
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: Colors.white, size: 40),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A self-contained numeric keypad (real-dialer layout) so the flow works
/// without the OS keyboard.
class _Keypad extends StatelessWidget {
  const _Keypad({required this.onKey});
  final ValueChanged<String> onKey;

  static const _rows = [
    [['1', ''], ['2', 'A B C'], ['3', 'D E F']],
    [['4', 'G H I'], ['5', 'J K L'], ['6', 'M N O']],
    [['7', 'P Q R S'], ['8', 'T U V'], ['9', 'W X Y Z']],
    [['', ''], ['0', '+'], ['<', '']],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final row in _rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                for (final k in row)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: k[0].isEmpty
                          ? const SizedBox(height: 56)
                          : _Key(
                              digit: k[0],
                              letters: k[1],
                              onTap: () => onKey(k[0]),
                            ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Key extends StatefulWidget {
  const _Key({
    required this.digit,
    required this.letters,
    required this.onTap,
  });
  final String digit;
  final String letters;
  final VoidCallback onTap;

  @override
  State<_Key> createState() => _KeyState();
}

class _KeyState extends State<_Key> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final isBack = widget.digit == '<';
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.92 : 1,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        child: Container(
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: _down
                  ? [S.surface, S.surface]
                  : const [S.surfaceTop, S.surfaceHi],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: S.hairSoft),
            boxShadow: _down ? null : S.key,
          ),
          child: isBack
              ? const Icon(Icons.backspace_rounded,
                  size: 22, color: S.inkMute)
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.digit,
                      style: const TextStyle(
                        fontFamily: S.font,
                        fontSize: 23,
                        height: 1.0,
                        fontWeight: FontWeight.w700,
                        color: S.ink,
                      ),
                    ),
                    if (widget.letters.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.letters,
                        style: const TextStyle(
                          fontFamily: S.font,
                          fontSize: 8.5,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w700,
                          color: S.inkFaint,
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

// ===========================================================================
// Step 3 — Select shipping region
// ===========================================================================

class RegionStep extends StatelessWidget {
  const RegionStep({
    super.key,
    required this.country,
    required this.selected,
    required this.onSelected,
    required this.onNext,
  });

  final Country country;
  final Region? selected;
  final ValueChanged<Region> onSelected;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _FlagChip(flag: country.flag, active: true),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                country.name,
                style: const TextStyle(
                  fontFamily: S.font,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: S.inkMute,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const _Intro(
          eyebrow: 'Almost there',
          title: 'Choose your\nregion',
          subtitle: 'We’ll route parcels through your nearest hub.',
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            itemCount: country.regions.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final r = country.regions[i];
              return _RegionCard(
                region: r,
                selected: r.name == selected?.name,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onSelected(r);
                },
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        PrimaryButton(
          label: 'Create account',
          icon: Icons.public_rounded,
          enabled: selected != null,
          onTap: onNext,
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

class _RegionCard extends StatelessWidget {
  const _RegionCard({
    required this.region,
    required this.selected,
    required this.onTap,
  });

  final Region region;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color.lerp(S.surface, S.accentA(0.10), selected ? 1 : 0),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Color.lerp(S.hair, S.accent, selected ? 1 : 0)!,
            width: 1.4,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? S.accent : S.surfaceHi,
                borderRadius: BorderRadius.circular(15),
                border: selected ? null : Border.all(color: S.hair),
              ),
              child: Icon(
                Icons.location_on_rounded,
                size: 22,
                color: selected ? Colors.white : S.inkMute,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    region.name,
                    style: const TextStyle(
                      fontFamily: S.font,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                      color: S.ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Hub · ${region.hub}',
                    style: const TextStyle(
                      fontFamily: S.font,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: S.inkMute,
                    ),
                  ),
                ],
              ),
            ),
            _EtaPill(eta: region.eta),
          ],
        ),
      ),
    );
  }
}

class _EtaPill extends StatelessWidget {
  const _EtaPill({required this.eta});
  final String eta;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: S.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: S.hair),
      ),
      child: Row(
        children: [
          const Icon(Icons.bolt_rounded, size: 14, color: S.accentHi),
          const SizedBox(width: 4),
          Text(
            eta,
            style: const TextStyle(
              fontFamily: S.font,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: S.ink,
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// Step 4 — The viral moment: world zooms into the country, then the success
// sheet rises over the planet.
// ===========================================================================

class LaunchStep extends StatefulWidget {
  const LaunchStep({
    super.key,
    required this.country,
    required this.region,
    required this.onStart,
  });

  final Country country;
  final Region region;
  final VoidCallback onStart;

  @override
  State<LaunchStep> createState() => _LaunchStepState();
}

class _LaunchStepState extends State<LaunchStep> with TickerProviderStateMixin {
  bool _zoom = false;
  bool _arrived = false;

  late final AnimationController _card = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 750),
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _zoom = true);
    });
  }

  void _onArrived() {
    if (_arrived) return;
    HapticFeedback.heavyImpact();
    setState(() => _arrived = true);
    _card.forward();
  }

  @override
  void dispose() {
    _card.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: S.bg,
      body: Stack(
        children: [
          Positioned.fill(
            child: WorldMapView(
              country: widget.country,
              zoom: _zoom,
              onArrived: _onArrived,
            ),
          ),

          // Status line while the camera is flying.
          Positioned(
            top: topInset + 28,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: _arrived ? 0 : 1,
                duration: const Duration(milliseconds: 300),
                child: Column(
                  children: [
                    Text(
                      widget.country.flag,
                      style: const TextStyle(fontSize: 26),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _zoom ? 'Locating your region' : 'Setting up your account',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: S.font,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                        color: S.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (_arrived)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedBuilder(
                animation: _card,
                builder: (_, child) {
                  final t = Curves.easeOutCubic.transform(_card.value);
                  return Opacity(
                    opacity: t,
                    child: Transform.translate(
                      offset: Offset(0, (1 - t) * 70),
                      child: child,
                    ),
                  );
                },
                child: _SuccessSheet(
                  country: widget.country,
                  region: widget.region,
                  onStart: widget.onStart,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SuccessSheet extends StatelessWidget {
  const _SuccessSheet({
    required this.country,
    required this.region,
    required this.onStart,
  });

  final Country country;
  final Region region;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          padding: EdgeInsets.fromLTRB(22, 14, 22, bottom + 22),
          decoration: BoxDecoration(
            color: S.surface.withValues(alpha: 0.86),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
            border: Border(top: BorderSide(color: S.hair)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: S.hair,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: S.accent,
                      shape: BoxShape.circle,
                      boxShadow: S.accentGlow,
                    ),
                    child: const Icon(Icons.check_rounded,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('You’re on the map', style: S.title.copyWith(
                          fontSize: 22,
                        )),
                        const SizedBox(height: 3),
                        const Text(
                          'Account created — welcome aboard.',
                          style: TextStyle(
                            fontFamily: S.font,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            color: S.inkMute,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: S.bg.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: S.hair),
                ),
                child: Row(
                  children: [
                    Text(country.flag, style: const TextStyle(fontSize: 30)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${region.name}, ${country.name}',
                            style: const TextStyle(
                              fontFamily: S.font,
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                              color: S.ink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Hub · ${region.hub} · ${region.eta}',
                            style: const TextStyle(
                              fontFamily: S.font,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: S.inkMute,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.public_rounded, color: S.accent, size: 22),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              PrimaryButton(
                label: 'Start shipping',
                icon: Icons.arrow_forward_rounded,
                onTap: onStart,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
