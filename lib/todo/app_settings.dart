import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'todo_theme.dart';

/// App-wide preferences (currently the accent colour), persisted and broadcast
/// so the whole UI recolors live when the user picks a new accent in Settings.
class AppSettings extends ChangeNotifier {
  static const _kAccent = 'accent_color_v1';

  /// Load saved prefs and apply them to [T] before the first frame.
  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    final value = p.getInt(_kAccent);
    if (value != null) T.accent = Color(value);
  }

  Color get accent => T.accent;

  Future<void> setAccent(Color c) async {
    if (c.toARGB32() == T.accent.toARGB32()) return;
    T.accent = c;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kAccent, c.toARGB32());
  }
}

/// Global singleton — simple and sufficient for a single-window app.
final appSettings = AppSettings();
