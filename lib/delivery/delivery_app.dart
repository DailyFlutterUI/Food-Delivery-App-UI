import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'delivery_theme.dart';
import 'track_screen.dart';

/// Bootstraps **Parcel** — a premium package-tracking app that walks an order
/// through six animated stages, from "Order Confirmed" to "Delivered".
class DeliveryApp extends StatelessWidget {
  const DeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: D.card,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    return MaterialApp(
      title: 'Parcel',
      debugShowCheckedModeBanner: false,
      theme: D.theme,
      home: const TrackScreen(),
    );
  }
}
