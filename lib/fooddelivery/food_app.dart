import 'package:flutter/material.dart';

import 'screens/main_shell.dart';
import 'theme/app_theme.dart';

/// Entry widget for the food-delivery prototype. Launch it from `main.dart`
/// with `runApp(const FoodApp());`.
class FoodApp extends StatelessWidget {
  const FoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Delivery',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const MainShell(),
      // Paint the warm peach→white wash once, behind every (transparent) route.
      builder: (context, child) {
        return DecoratedBox(
          decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
