import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'add_task_sheet.dart';
import 'celebration.dart';
import 'sparkle_burst.dart';
import 'task.dart';
import 'task_tile.dart';
import 'todo_theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final _store = taskStore;
  TaskFilter _filter = TaskFilter.all;

  // Staggered entrance for the whole screen on first paint.
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    _store.addListener(_onStoreChanged);
    _store.load().then((_) => _intro.forward());
  }

  void _onStoreChanged() => setState(() {});

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
    _intro.dispose();
    super.dispose();
  }

  void _toggle(String id, Offset checkboxCenter) {
    final nowDone = _store.toggle(id);
    if (nowDone) {
      HapticFeedback.mediumImpact();
      SparkleBurst.at(context, checkboxCenter);
      if (_store.allDone) Celebration.play(context);
    }
  }

  void _openAdd() {
    AddTaskSheet.show(context, onSubmit: _store.add);
  }

  void _editTask(Task t) {
    HapticFeedback.selectionClick();
    AddTaskSheet.show(
      context,
      initialTitle: t.title,
      initialEmoji: t.emoji,
      onSubmit: (title, emoji) => _store.edit(t.id, title, emoji),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_store.loaded) {
      return Scaffold(
        backgroundColor: T.bg,
        body: Center(
          child: CircularProgressIndicator(color: T.accent, strokeWidth: 3),
        ),
      );
    }

    final visible = _store.filtered(_filter);
    return Scaffold(
      backgroundColor: T.bg,
      floatingActionButton: _AddButton(onTap: _openAdd),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _header()),
            SliverToBoxAdapter(child: _filterBar()),
            if (visible.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyState(filter: _filter),
              )
            else if (_filter == TaskFilter.all)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
                sliver: SliverReorderableList(
                  itemCount: visible.length,
                  onReorder: _store.reorder,
                  proxyDecorator: _liftProxy,
                  itemBuilder: (context, i) => _tileFor(visible[i], i,
                      key: ValueKey(visible[i].id), reorderable: true),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
                sliver: SliverList.builder(
                  itemCount: visible.length,
                  itemBuilder: (context, i) => _tileFor(visible[i], i,
                      key: ValueKey(visible[i].id), reorderable: false),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _tileFor(Task task, int index,
      {required Key key, required bool reorderable}) {
    return _Staggered(
      key: key,
      controller: _intro,
      index: index,
      child: TaskTile(
        task: task,
        onToggle: (center) => _toggle(task.id, center),
        onDelete: () => _store.remove(task.id),
        onEdit: () => _editTask(task),
        dragHandle: reorderable
            ? ReorderableDragStartListener(
                index: index,
                child: const Icon(Icons.drag_indicator_rounded,
                    color: T.inkFaint, size: 22),
              )
            : null,
      ),
    );
  }

  /// Lift effect while a row is being dragged for reorder.
  Widget _liftProxy(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, _) {
        final t = Curves.easeOut.transform(animation.value);
        return Transform.scale(
          scale: 1 + 0.04 * t,
          child: Material(color: Colors.transparent, child: child),
        );
      },
      child: child,
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _store.allDone ? 'All done! 🎉' : 'Hello there 👋',
                  style: const TextStyle(
                    fontFamily: T.font,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: T.inkSoft,
                  ),
                ),
              ),
              if (_store.streak > 0) _StreakChip(streak: _store.streak),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'My little tasks',
            style: TextStyle(
              fontFamily: T.fontDisplay,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
              color: T.ink,
            ),
          ),
          const SizedBox(height: 18),
          _ProgressCard(
            completed: _store.completed,
            total: _store.total,
            progress: _store.progress,
          ),
        ],
      ),
    );
  }

  Widget _filterBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 2),
      child: Row(
        children: [
          for (final f in TaskFilter.values) ...[
            _FilterPill(
              label: _filterLabel(f),
              selected: _filter == f,
              onTap: () => setState(() => _filter = f),
            ),
            const SizedBox(width: 8),
          ],
          const Spacer(),
          if (_store.completed > 0)
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _store.clearDone();
              },
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  'Clear done',
                  style: TextStyle(
                    fontFamily: T.font,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: T.accent,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _filterLabel(TaskFilter f) {
    switch (f) {
      case TaskFilter.all:
        return 'All';
      case TaskFilter.active:
        return 'Active';
      case TaskFilter.done:
        return 'Done';
    }
  }
}

class _StreakChip extends StatelessWidget {
  const _StreakChip({required this.streak});
  final int streak;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: T.accentWash,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 5),
          Text(
            '$streak day${streak == 1 ? '' : 's'}',
            style: TextStyle(
              fontFamily: T.font,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: T.accentDeep,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? T.accent : T.card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: selected ? null : T.cardShadow,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: T.font,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : T.inkSoft,
          ),
        ),
      ),
    );
  }
}

/// Soft card showing how many tasks are done with the animated ring.
class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.completed,
    required this.total,
    required this.progress,
  });

  final int completed;
  final int total;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: T.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: T.cardShadow,
      ),
      child: Row(
        children: [
          _Ring(progress: progress),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  total == 0
                      ? 'Nothing yet'
                      : (completed == total
                          ? 'Everything is done 💖'
                          : '$completed of $total done'),
                  style: const TextStyle(
                    fontFamily: T.fontDisplay,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: T.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  total == 0
                      ? 'Add a task to begin'
                      : (completed == total
                          ? 'Enjoy your day'
                          : 'Keep going, you got this'),
                  style: const TextStyle(
                    fontFamily: T.font,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: T.inkSoft,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  const _Ring({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: progress),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
        builder: (_, v, _) => Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: v,
              strokeWidth: 6,
              strokeCap: StrokeCap.round,
              backgroundColor: T.bgSoft,
              valueColor: AlwaysStoppedAnimation<Color>(T.accent),
            ),
            Text(
              '${(v * 100).round()}%',
              style: const TextStyle(
                fontFamily: T.font,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: T.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Wraps a child in a fade + slide that begins at a staggered offset based on
/// its list index — gives the list a gentle cascade on entry.
class _Staggered extends StatelessWidget {
  const _Staggered({
    super.key,
    required this.controller,
    required this.index,
    required this.child,
  });

  final AnimationController controller;
  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final start = (index * 0.08).clamp(0.0, 0.6);
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
          offset: Offset(0, 16 * (1 - anim.value)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.filter});

  final TaskFilter filter;

  @override
  Widget build(BuildContext context) {
    final (asset, title, subtitle) = switch (filter) {
      TaskFilter.active => ('popper', 'Nothing left to do', 'You finished everything!'),
      TaskFilter.done => ('sparkles', 'No finished tasks yet', 'Completed tasks land here'),
      TaskFilter.all => ('sunflower', 'All clear!', 'Tap + to add your first little task'),
    };
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Gently bobbing glossy 3D mascot.
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(seconds: 2),
            curve: Curves.easeInOut,
            builder: (_, v, child) => Transform.translate(
              offset: Offset(0, -6 * (0.5 - (v - 0.5).abs()) * 2),
              child: child,
            ),
            child: Container(
              width: 120,
              height: 120,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: T.bgSoft,
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                T.emoji(asset),
                width: 66,
                height: 66,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontFamily: T.fontDisplay,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: T.ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              fontFamily: T.font,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: T.inkSoft,
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

/// Soft, pulsing add button.
class _AddButton extends StatefulWidget {
  const _AddButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<_AddButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, child) {
          final glow = 14 + _c.value * 10;
          return Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: T.accent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: T.accentGlow,
                  blurRadius: glow,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: child,
          );
        },
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
      ),
    );
  }
}
