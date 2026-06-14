import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../widgets/auth_field.dart';
import '../widgets/brand_logos.dart';
import '../widgets/primary_button.dart';
import 'main_shell.dart';
import 'register_screen.dart';

/// A warm, appetising spread — the hero photo for sign-in.
const String kLoginHeroImage =
    'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=1000&q=80';

/// Smooth cross-fade transition shared by the auth screens. The page-level
/// motion is kept to a plain opacity fade so it never slides the whole heavy
/// subtree (photo + gradients) around — the per-widget [AuthStaggerItem]
/// entrance supplies the polish instead, exactly like the profile screen.
Route<T> authFadeRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (_, _, _) => page,
    transitionsBuilder: (context, animation, _, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      );
    },
  );
}

/// Reveals [child] on its own slice of a shared intro [animation] — a fade
/// paired with a small upward slide, staggered by [index] so the widgets arrive
/// one by one. Lifted from the profile screen's `_StaggerItem` so the auth
/// screens animate in with the same restrained, premium cadence.
class AuthStaggerItem extends StatelessWidget {
  const AuthStaggerItem({
    super.key,
    required this.animation,
    required this.index,
    required this.count,
    required this.child,
    this.slide = true,
  });

  final Animation<double> animation;
  final int index;
  final int count;
  final Widget child;
  final bool slide;

  @override
  Widget build(BuildContext context) {
    const span = 0.6; // fraction of the timeline each widget takes to fade in
    final maxStart = 1.0 - span;
    final start = count <= 1 ? 0.0 : (index / (count - 1)) * maxStart;
    final curved = CurvedAnimation(
      parent: animation,
      curve: Interval(start, start + span, curve: Curves.easeOutCubic),
    );
    final faded = FadeTransition(opacity: curved, child: child);
    if (!slide) return faded;
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.08),
        end: Offset.zero,
      ).animate(curved),
      child: faded,
    );
  }
}

/// Premium sign-in screen. A real food hero crowns a clean form so the brand
/// sells the appetite before the user types a thing. Everything is sized to sit
/// on a single screen — no scrolling. The burnt-orange accent appears exactly
/// once, on the primary action.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool _precached = false;

  /// 0→1 entrance timeline; each widget reveals on its own slice of it, the
  /// same staggered fade the profile screen uses for its rows.
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    _intro.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Warm the sign-up hero into the image cache now, so navigating to it later
    // shows the photo immediately instead of flashing a blank gap.
    if (!_precached) {
      _precached = true;
      precacheImage(const NetworkImage(kRegisterHeroImage), context);
    }
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  void _enter(BuildContext context) {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const MainShell()));
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final heroH = (screenH * 0.30).clamp(188.0, 280.0);
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.transparent,
      // Let the body shrink with the keyboard so the scroll view below can
      // bring the focused field into view.
      resizeToAvoidBottomInset: true,
      // Fills the screen as a fixed page when there's room; once the keyboard
      // claims space the content exceeds the viewport and becomes scrollable.
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // Hero fades in first, without a slide so the photo stays anchored.
                    AuthStaggerItem(
                      animation: _intro,
                      index: 0,
                      count: 9,
                      slide: false,
                      child: AuthHero(
                        height: heroH,
                        imageUrl: kLoginHeroImage,
                        badge: 'WELCOME BACK',
                        title: 'Good food is\nwaiting for you',
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          24,
                          22,
                          24,
                          14 + bottomInset,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AuthStaggerItem(
                              animation: _intro,
                              index: 1,
                              count: 9,
                              child: Text(
                                'Sign in',
                                style: AppText.display.copyWith(fontSize: 26),
                              ),
                            ),
                            const Spacer(flex: 2),
                            AuthStaggerItem(
                              animation: _intro,
                              index: 2,
                              count: 9,
                              child: const AuthField(
                                label: 'EMAIL',
                                hint: 'you@example.com',
                                icon: Icons.alternate_email_rounded,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                              ),
                            ),
                            const SizedBox(height: 14),
                            AuthStaggerItem(
                              animation: _intro,
                              index: 3,
                              count: 9,
                              child: const AuthField(
                                label: 'PASSWORD',
                                hint: 'Your password',
                                icon: Icons.lock_outline_rounded,
                                obscure: true,
                                textInputAction: TextInputAction.done,
                              ),
                            ),
                            const SizedBox(height: 10),
                            AuthStaggerItem(
                              animation: _intro,
                              index: 4,
                              count: 9,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {},
                                  child: Text(
                                    'Forgot password?',
                                    style: AppText.label.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(flex: 3),
                            AuthStaggerItem(
                              animation: _intro,
                              index: 5,
                              count: 9,
                              child: PrimaryButton(
                                label: 'Sign in',
                                icon: Icons.arrow_forward_rounded,
                                showShadow: false,
                                onPressed: () => _enter(context),
                              ),
                            ),
                            const Spacer(flex: 2),
                            AuthStaggerItem(
                              animation: _intro,
                              index: 6,
                              count: 9,
                              child: const AuthDivider(
                                label: 'or continue with',
                              ),
                            ),
                            const SizedBox(height: 16),
                            AuthStaggerItem(
                              animation: _intro,
                              index: 7,
                              count: 9,
                              child: Row(
                                children: const [
                                  SocialButton(
                                    label: 'Google',
                                    child: GoogleLogo(),
                                  ),
                                  SizedBox(width: 14),
                                  SocialButton(
                                    label: 'Facebook',
                                    child: FacebookLogo(),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(flex: 2),
                            AuthStaggerItem(
                              animation: _intro,
                              index: 8,
                              count: 9,
                              child: AuthSwitchPrompt(
                                question: "Don't have an account?",
                                action: 'Sign up',
                                onTap: () => Navigator.of(
                                  context,
                                ).push(authFadeRoute(const RegisterScreen())),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Shared photographic header used by both auth screens. The real food image
/// sits over the app's warm wash, so it degrades gracefully to a peach glow if
/// the photo can't load.
class AuthHero extends StatelessWidget {
  const AuthHero({
    super.key,
    required this.badge,
    required this.title,
    required this.imageUrl,
    this.height = 320,
  });

  final String badge;
  final String title;
  final String imageUrl;
  final double height;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    // The status bar sits over the dark hero photo, so paint its clock, wifi
    // and battery glyphs white for legibility.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: SizedBox(
        height: height + topInset,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Warm base — also the fallback if the network photo is unavailable.
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primaryDeep, Color(0xFF1F1206)],
                ),
              ),
            ),
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              // Hold the last decoded frame across rebuilds so the photo never
              // blinks out when the screen animates in.
              gaplessPlayback: true,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
              loadingBuilder: (context, child, progress) =>
                  progress == null ? child : const SizedBox.shrink(),
              // Soft fade-in the first time a frame arrives (skipped when the
              // image is already cached, so it appears instantly).
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded) return child;
                return AnimatedOpacity(
                  opacity: frame == null ? 0 : 1,
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOut,
                  child: child,
                );
              },
            ),
            // Legibility + seam: darken the photo and melt its base into the page.
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.25),
                    Colors.black.withValues(alpha: 0.10),
                    AppColors.background,
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24, topInset + 26, 24, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const _BrandMark(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Text(
                          badge,
                          style: AppText.eyebrow.copyWith(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: AppTheme.displayFont,
                          color: Colors.white,
                          fontSize: 30,
                          height: 1.12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Savory',
          style: TextStyle(
            fontFamily: AppTheme.displayFont,
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
      ],
    );
  }
}

/// A hairline rule with a centred label — "or continue with".
class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final line = Expanded(child: Divider(color: AppColors.hairline));
    return Row(
      children: [
        line,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(label, style: AppText.label),
        ),
        line,
      ],
    );
  }
}

/// Bottom "Don't have an account? Sign up" toggle shared by both screens.
class AuthSwitchPrompt extends StatelessWidget {
  const AuthSwitchPrompt({
    super.key,
    required this.question,
    required this.action,
    required this.onTap,
  });

  final String question;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Text.rich(
          TextSpan(
            text: '$question  ',
            style: AppText.body,
            children: [
              TextSpan(
                text: action,
                style: AppText.body.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
