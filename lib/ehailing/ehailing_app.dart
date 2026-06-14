import 'package:flutter/material.dart';

import 'ehailing_theme.dart';
import 'landing_screen.dart';
import 'service_mode.dart';

/// Entry widget for the e-hailing app. Self-contained: it does not touch any
/// of the to-do app code in `lib/todo/`.
class EHailingApp extends StatelessWidget {
  const EHailingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Move',
      debugShowCheckedModeBanner: false,
      theme: E.theme(ModeConfig.all[ServiceMode.ride]!.accent),
      home: const EHailingLanding(),
    );
  }
}
