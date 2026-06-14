import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'fooddelivery/food_app.dart';

// Earlier prototypes are preserved under lib/: the "Little Tasks" to-do app in
// `lib/todo/`, the e-hailing demo in `lib/ehailing/`, the "Money Rain" savings
// app in `lib/savings/`, the delivery flow in `lib/delivery/`, and the
// food-delivery UI in `lib/fooddelivery/` (running below). To run another
// instead, import its app widget and pass it to runApp() — e.g.
// `import 'delivery/signup/signup_flow.dart';` then `runApp(const GlobalSignupApp());`.

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));
  runApp(const FoodApp());
}
