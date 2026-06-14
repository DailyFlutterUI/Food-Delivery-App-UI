import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'home_screen.dart';
import 'intro_screen.dart';
import 'savings_store.dart';
import 'savings_theme.dart';

/// Bootstraps **Money Rain** — a premium little savings app where saved money
/// falls as golden coins and fills a jar, with a golden-rain burst at every
/// milestone. Call `await savingsStore.load()` then `runApp(const MoneyRainApp())`.
class MoneyRainApp extends StatelessWidget {
  const MoneyRainApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: S.bg,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    return MaterialApp(
      title: 'Money Rain',
      debugShowCheckedModeBanner: false,
      theme: S.theme,
      home: const _Root(),
    );
  }
}

class _Root extends StatefulWidget {
  const _Root();

  @override
  State<_Root> createState() => _RootState();
}

class _RootState extends State<_Root> {
  bool _showIntro = true;

  @override
  void initState() {
    super.initState();
    // Warm the store so the home screen opens with data already loaded.
    savingsStore.load();
  }

  void _finishIntro() => setState(() => _showIntro = false);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      child: _showIntro
          ? IntroScreen(key: const ValueKey('intro'), onDone: _finishIntro)
          : const HomeScreen(key: ValueKey('home')),
    );
  }
}
