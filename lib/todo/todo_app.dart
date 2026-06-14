import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_settings.dart';
import 'intro_page.dart';
import 'main_shell.dart';
import 'todo_theme.dart';

/// Bootstraps the original "Little Tasks" to-do app. Preserved intact and kept
/// compilable. To launch it instead of the e-hailing app, in `main.dart` call
/// `await appSettings.load();` then `runApp(const CuteTodoApp());`.
class CuteTodoApp extends StatefulWidget {
  const CuteTodoApp({super.key});

  @override
  State<CuteTodoApp> createState() => _CuteTodoAppState();
}

class _CuteTodoAppState extends State<CuteTodoApp> {
  @override
  void initState() {
    super.initState();
    // Rebuild the whole app (new theme + recoloured widgets) on accent change.
    appSettings.addListener(_onChanged);
  }

  @override
  void dispose() {
    appSettings.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: T.bg,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    return MaterialApp(
      title: 'Little Tasks',
      debugShowCheckedModeBanner: false,
      theme: T.theme,
      home: const _Root(),
    );
  }
}

/// Always opens on the intro, then moves to the app when it's finished.
class _Root extends StatefulWidget {
  const _Root();

  @override
  State<_Root> createState() => _RootState();
}

class _RootState extends State<_Root> {
  bool _showIntro = true; // shown on every launch

  void _finishIntro() => setState(() => _showIntro = false);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: _showIntro
          ? IntroPage(key: const ValueKey('intro'), onDone: _finishIntro)
          : const MainShell(key: ValueKey('shell')),
    );
  }
}
