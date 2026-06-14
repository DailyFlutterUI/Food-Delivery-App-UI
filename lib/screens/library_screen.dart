import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/ambient_background.dart';
import '../widgets/common.dart';
import '../widgets/glass.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  static const _notes = [
    (
      title: 'Product strategy sync',
      tag: 'Notes',
      icon: Icons.description_outlined,
      tint: AppColors.accentBlue,
      lines: 12,
    ),
    (
      title: 'Biology — cell division',
      tag: 'Quiz',
      icon: Icons.help_outline,
      tint: AppColors.accentViolet,
      lines: 8,
    ),
    (
      title: 'Podcast: future of AI',
      tag: 'Audio',
      icon: Icons.graphic_eq,
      tint: AppColors.accentRose,
      lines: 24,
    ),
    (
      title: 'Q3 financials brief',
      tag: 'Docs',
      icon: Icons.folder_open,
      tint: AppColors.accentCyan,
      lines: 16,
    ),
    (
      title: 'Design crit notes',
      tag: 'Notes',
      icon: Icons.description_outlined,
      tint: AppColors.accentViolet,
      lines: 9,
    ),
    (
      title: 'Interview transcript',
      tag: 'Chat',
      icon: Icons.chat_bubble_outline,
      tint: AppColors.accentBlue,
      lines: 31,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
                child: Row(
                  children: [
                    const SparkMark(size: 24),
                    const SizedBox(width: 10),
                    Text(
                      'Your Library',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const Spacer(),
                    GlassIconButton(icon: Icons.search, size: 42, onTap: () {}),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: Text(
                  '6 notes • synced just now',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.84,
                  ),
                  itemCount: _notes.length,
                  itemBuilder: (context, i) {
                    final n = _notes[i];
                    return FadeSlideIn(
                      index: i,
                      child: _NoteCard(
                        title: n.title,
                        tag: n.tag,
                        icon: n.icon,
                        tint: n.tint,
                        lines: n.lines,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.title,
    required this.tag,
    required this.icon,
    required this.tint,
    required this.lines,
  });

  final String title;
  final String tag;
  final IconData icon;
  final Color tint;
  final int lines;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 22,
      padding: const EdgeInsets.all(16),
      onTap: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      tint.withValues(alpha: 0.35),
                      tint.withValues(alpha: 0.12),
                    ],
                  ),
                  border: Border.all(color: AppColors.glassBorderSoft),
                ),
                child: Icon(icon, size: 18, color: Colors.white),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.glass,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.glassBorderSoft),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontWeight: FontWeight.w700,
              fontSize: 15,
              height: 1.25,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          // Faux summary lines.
          for (int l = 0; l < 3; l++)
            Container(
              margin: const EdgeInsets.only(top: 6),
              height: 5,
              width: l == 2 ? 60 : double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.notes, size: 13, color: AppColors.textMuted),
              const SizedBox(width: 5),
              Text(
                '$lines min read',
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 11.5,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
