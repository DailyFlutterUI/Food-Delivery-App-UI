import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/ambient_background.dart';
import '../widgets/common.dart';
import '../widgets/glass.dart';
import '../widgets/gradient_button.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  static const _items = [
    (icon: Icons.language, label: 'Change Language'),
    (icon: Icons.cloud_off_outlined, label: 'Failed Upload'),
    (icon: Icons.person_outline, label: 'Account Details'),
    (icon: Icons.mail_outline, label: 'Contact Support'),
    (icon: Icons.public, label: 'Go to Website'),
    (icon: Icons.restore, label: 'Restore Purchases'),
    (icon: Icons.workspace_premium_outlined, label: 'Rate us Premium'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _header(context),
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  itemCount: _items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final item = _items[i];
                    return FadeSlideIn(
                      index: i,
                      child: _SettingRow(icon: item.icon, label: item.label),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 90),
                child: FadeSlideIn(
                  index: _items.length,
                  child: GradientButton(
                    label: 'Log Out',
                    icon: Icons.logout,
                    onPressed: () => _confirmLogout(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          GlassIconButton(icon: Icons.chevron_left, onTap: onBack),
          const Spacer(),
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.glass,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: const Text(
                  'Settings',
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
          GlassIconButton(icon: Icons.tune, onTap: () {}),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
            decoration: BoxDecoration(
              color: AppColors.bgElevated.withValues(alpha: 0.7),
              border: Border(
                top: BorderSide(color: AppColors.glassBorder),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Log out?',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'You can always sign back in anytime.',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 22),
                GradientButton(
                  label: 'Log Out',
                  onPressed: () => Navigator.pop(ctx),
                ),
                const SizedBox(height: 10),
                Pressable(
                  onTap: () => Navigator.pop(ctx),
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppColors.textMuted,
                      ),
                    ),
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

class _SettingRow extends StatelessWidget {
  const _SettingRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      onTap: () {},
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.accentViolet.withValues(alpha: 0.25),
                  AppColors.accentRose.withValues(alpha: 0.15),
                ],
              ),
              border: Border.all(color: AppColors.glassBorderSoft),
            ),
            child: Icon(icon, size: 18, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.glass,
              border: Border.all(color: AppColors.glassBorderSoft),
            ),
            child: const Icon(Icons.chevron_right,
                size: 16, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
