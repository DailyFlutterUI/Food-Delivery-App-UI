import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/auth_field.dart';
import '../widgets/brand_logos.dart';
import '../widgets/primary_button.dart';
import 'login_screen.dart';
import 'main_shell.dart';

/// A plated, restaurant-grade dish — a more refined hero for account creation.
const String kRegisterHeroImage =
    'https://images.unsplash.com/photo-1467003909585-2f8a72700288?auto=format&fit=crop&w=1000&q=80';

/// Premium account-creation screen — same photographic hero and form language
/// as [LoginScreen] so the two read as one flow. Adds a name field and a terms
/// agreement; the accent still lands only on the primary action.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  bool _agreed = false;
  bool _precached = false;

  /// Same staggered-fade entrance as the sign-in and profile screens.
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 950),
  );

  @override
  void initState() {
    super.initState();
    _intro.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Keep the sign-in hero warm so toggling back is instant.
    if (!_precached) {
      _precached = true;
      precacheImage(const NetworkImage(kLoginHeroImage), context);
    }
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  void _enter() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShell()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: [
              AuthStaggerItem(
                animation: _intro,
                index: 0,
                count: 10,
                slide: false,
                child: const AuthHero(
                  badge: 'JOIN SAVORY',
                  title: 'Create an account\nin moments',
                  imageUrl: kRegisterHeroImage,
                  height: 300,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AuthStaggerItem(
                      animation: _intro,
                      index: 1,
                      count: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Sign up', style: AppText.display),
                          const SizedBox(height: 6),
                          Text(
                            'A few details and your first order is on its way.',
                            style: AppText.body,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    AuthStaggerItem(
                      animation: _intro,
                      index: 2,
                      count: 10,
                      child: const AuthField(
                        label: 'FULL NAME',
                        hint: 'Jamie Rivera',
                        icon: Icons.person_outline_rounded,
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    const SizedBox(height: 18),
                    AuthStaggerItem(
                      animation: _intro,
                      index: 3,
                      count: 10,
                      child: const AuthField(
                        label: 'EMAIL',
                        hint: 'you@example.com',
                        icon: Icons.alternate_email_rounded,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    const SizedBox(height: 18),
                    AuthStaggerItem(
                      animation: _intro,
                      index: 4,
                      count: 10,
                      child: const AuthField(
                        label: 'PASSWORD',
                        hint: 'At least 8 characters',
                        icon: Icons.lock_outline_rounded,
                        obscure: true,
                        textInputAction: TextInputAction.done,
                      ),
                    ),
                    const SizedBox(height: 20),
                    AuthStaggerItem(
                      animation: _intro,
                      index: 5,
                      count: 10,
                      child: _TermsRow(
                        agreed: _agreed,
                        onToggle: () => setState(() => _agreed = !_agreed),
                      ),
                    ),
                    const SizedBox(height: 24),
                    AuthStaggerItem(
                      animation: _intro,
                      index: 6,
                      count: 10,
                      child: PrimaryButton(
                        label: 'Create account',
                        icon: Icons.arrow_forward_rounded,
                        showShadow: false,
                        onPressed: _enter,
                      ),
                    ),
                    const SizedBox(height: 26),
                    AuthStaggerItem(
                      animation: _intro,
                      index: 7,
                      count: 10,
                      child: const AuthDivider(label: 'or sign up with'),
                    ),
                    const SizedBox(height: 20),
                    AuthStaggerItem(
                      animation: _intro,
                      index: 8,
                      count: 10,
                      child: Row(
                        children: const [
                          SocialButton(label: 'Google', child: GoogleLogo()),
                          SizedBox(width: 14),
                          SocialButton(
                              label: 'Facebook', child: FacebookLogo()),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    AuthStaggerItem(
                      animation: _intro,
                      index: 9,
                      count: 10,
                      child: AuthSwitchPrompt(
                        question: 'Already have an account?',
                        action: 'Sign in',
                        onTap: () {
                          // Pop back to the live sign-in screen when it's on
                          // the stack — reverses the same smooth transition.
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          } else {
                            Navigator.of(context).pushReplacement(
                              authFadeRoute(const LoginScreen()),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Frosted back affordance over the hero.
          Positioned(
            top: MediaQuery.of(context).padding.top + 18,
            right: 20,
            child: _CloseButton(onTap: () => Navigator.of(context).maybePop()),
          ),
        ],
      ),
    );
  }
}

class _TermsRow extends StatelessWidget {
  const _TermsRow({required this.agreed, required this.onToggle});

  final bool agreed;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onToggle,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: agreed ? AppColors.primary : AppColors.card,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: agreed ? AppColors.primary : AppColors.hairline,
                width: 1.4,
              ),
            ),
            child: agreed
                ? const Icon(Icons.check_rounded,
                    size: 15, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Text.rich(
                TextSpan(
                  text: 'I agree to the ',
                  style: AppText.body.copyWith(fontSize: 12.5),
                  children: [
                    TextSpan(
                      text: 'Terms',
                      style: AppText.body.copyWith(
                        fontSize: 12.5,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: AppText.body.copyWith(
                        fontSize: 12.5,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.18),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: const Icon(Icons.close_rounded,
              size: 20, color: Colors.white),
        ),
      ),
    );
  }
}
