import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Account tab — header card, quick stats, and a settings list.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Profile', style: AppText.h1),
              _CircleIcon(icon: Icons.settings_outlined, onTap: () {}),
            ],
          ),
          const SizedBox(height: 22),
          _ProfileHeader(),
          const SizedBox(height: 18),
          Row(
            children: const [
              Expanded(child: _StatCard(value: '48', label: 'Orders')),
              SizedBox(width: 12),
              Expanded(child: _StatCard(value: '12', label: 'Vouchers')),
              SizedBox(width: 12),
              Expanded(child: _StatCard(value: '4.9', label: 'Rating')),
            ],
          ),
          const SizedBox(height: 26),
          const Text('ACCOUNT', style: AppText.eyebrow),
          const SizedBox(height: 12),
          _MenuGroup(items: const [
            (icon: Icons.receipt_long_rounded, label: 'My orders'),
            (icon: Icons.favorite_border_rounded, label: 'Favourites'),
            (icon: Icons.location_on_outlined, label: 'Saved addresses'),
            (icon: Icons.credit_card_rounded, label: 'Payment methods'),
          ]),
          const SizedBox(height: 22),
          const Text('MORE', style: AppText.eyebrow),
          const SizedBox(height: 12),
          _MenuGroup(items: const [
            (icon: Icons.notifications_none_rounded, label: 'Notifications'),
            (icon: Icons.help_outline_rounded, label: 'Help centre'),
            (icon: Icons.logout_rounded, label: 'Log out'),
          ]),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDeep, Color(0xFF1F1206)],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.floating,
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
            ),
            alignment: Alignment.center,
            child: const Text('🧑🏽', style: TextStyle(fontSize: 30)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Adi Pratama',
                  style: TextStyle(
                    fontFamily: AppTheme.displayFont,
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'adi.pratama@email.com',
                  style: AppText.label.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Edit',
              style: AppText.label.copyWith(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Column(
        children: [
          Text(value, style: AppText.price.copyWith(fontSize: 20)),
          const SizedBox(height: 4),
          Text(label, style: AppText.label.copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}

typedef _MenuItem = ({IconData icon, String label});

class _MenuGroup extends StatelessWidget {
  const _MenuGroup({required this.items});

  final List<_MenuItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _MenuRow(item: items[i]),
            if (i != items.length - 1)
              const Divider(indent: 56, endIndent: 16),
          ],
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.item});

  final _MenuItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Icon(item.icon, size: 21, color: AppColors.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Text(item.label,
                  style: AppText.title.copyWith(fontSize: 14)),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textMuted, size: 22),
          ],
        ),
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.hairline),
          ),
          child: Icon(icon, size: 22, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
