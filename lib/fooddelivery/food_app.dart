import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'theme/app_theme.dart';
import 'theme/food_theme.dart';

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
      home: const LoginScreen(),
      // Paint the warm wash once, behind every (transparent) route, and rebuild
      // it as the app morphs between Daylight and Midnight.
      builder: (context, child) {
        final safeChild = child ?? const SizedBox.shrink();
        return ListenableBuilder(
          listenable: FoodTheme.instance,
          builder: (context, _) => DecoratedBox(
            decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
            child: safeChild,
          ),
        );
      },
    );
  }
}
