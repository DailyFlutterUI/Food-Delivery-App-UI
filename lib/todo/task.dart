import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A single to-do item. Cuteness lives in the [emoji] tag.
class Task {
  Task({
    required this.id,
    required this.title,
    this.emoji = '🌸',
    this.done = false,
  });

  final String id;
  String title;
  String emoji;
  bool done;

  Map<String, dynamic> toJson() =>
      {'id': id, 'title': title, 'emoji': emoji, 'done': done};

  factory Task.fromJson(Map<String, dynamic> j) => Task(
        id: j['id'] as String,
        title: j['title'] as String,
        emoji: (j['emoji'] as String?) ?? '🌸',
        done: (j['done'] as bool?) ?? false,
      );
}

/// The little palette of category emoji offered in the add sheet.
const List<String> kEmojiChoices = [
  '🌸', '☕️', '📚', '💪', '🧺', '🛒',
  '🎨', '🎧', '🌱', '💌', '🐱', '✨',
];

/// How the list is filtered in the UI.
enum TaskFilter { all, active, done }

/// Task store backed by [SharedPreferences]. Holds tasks plus a daily
/// completion streak. Call [load] once at startup.
class TaskStore extends ChangeNotifier {
  static const _kTasks = 'tasks_v1';
  static const _kStreak = 'streak_count';
  static const _kLastActive = 'streak_last_active'; // yyyy-mm-dd

  final List<Task> _tasks = [];
  int _streak = 0;
  String? _lastActive;
  bool _loaded = false;

  bool get loaded => _loaded;
  int get streak => _streak;

  List<Task> get tasks => List.unmodifiable(_tasks);

  List<Task> filtered(TaskFilter f) {
    switch (f) {
      case TaskFilter.all:
        return tasks;
      case TaskFilter.active:
        return _tasks.where((t) => !t.done).toList();
      case TaskFilter.done:
        return _tasks.where((t) => t.done).toList();
    }
  }

  int get total => _tasks.length;
  int get completed => _tasks.where((t) => t.done).length;
  double get progress => total == 0 ? 0 : completed / total;
  bool get allDone => total > 0 && completed == total;

  // ---- persistence ----------------------------------------------------------

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_kTasks);
    if (raw != null) {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      _tasks
        ..clear()
        ..addAll(list.map(Task.fromJson));
    } else {
      _tasks.addAll(_seed());
    }
    _streak = p.getInt(_kStreak) ?? 0;
    _lastActive = p.getString(_kLastActive);
    // If the last active day is older than yesterday, the streak has lapsed.
    if (_lastActive != null &&
        _lastActive != _today() &&
        _lastActive != _yesterday()) {
      _streak = 0;
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(
        _kTasks, jsonEncode(_tasks.map((t) => t.toJson()).toList()));
    await p.setInt(_kStreak, _streak);
    if (_lastActive != null) await p.setString(_kLastActive, _lastActive!);
  }

  // ---- mutations ------------------------------------------------------------

  void add(String title, String emoji) {
    final id = 't${DateTime.now().microsecondsSinceEpoch}';
    _tasks.insert(0, Task(id: id, title: title.trim(), emoji: emoji));
    _save();
    notifyListeners();
  }

  void edit(String id, String title, String emoji) {
    final t = _tasks.firstWhere((t) => t.id == id);
    t.title = title.trim();
    t.emoji = emoji;
    _save();
    notifyListeners();
  }

  /// Returns the new done state so the caller can fire celebration effects.
  bool toggle(String id) {
    final t = _tasks.firstWhere((t) => t.id == id);
    t.done = !t.done;
    if (t.done) _bumpStreak();
    _save();
    notifyListeners();
    return t.done;
  }

  void remove(String id) {
    _tasks.removeWhere((t) => t.id == id);
    _save();
    notifyListeners();
  }

  void clearDone() {
    _tasks.removeWhere((t) => t.done);
    _save();
    notifyListeners();
  }

  void clearAll() {
    _tasks.clear();
    _save();
    notifyListeners();
  }

  void reorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final t = _tasks.removeAt(oldIndex);
    _tasks.insert(newIndex, t);
    _save();
    notifyListeners();
  }

  // ---- streak ---------------------------------------------------------------

  void _bumpStreak() {
    final today = _today();
    if (_lastActive == today) return; // already counted today
    _streak = _lastActive == _yesterday() ? _streak + 1 : 1;
    _lastActive = today;
  }

  String _today() => _fmt(DateTime.now());
  String _yesterday() =>
      _fmt(DateTime.now().subtract(const Duration(days: 1)));
  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  List<Task> _seed() => [
        Task(id: 't1', title: 'Water the little plant', emoji: '🌱'),
        Task(id: 't2', title: 'Morning matcha', emoji: '☕️', done: true),
        Task(id: 't3', title: 'Read 10 pages', emoji: '📚'),
        Task(id: 't4', title: 'Stretch for 5 min', emoji: '💪'),
      ];
}

/// Shared singleton so the home list and Settings act on the same data.
final taskStore = TaskStore();
