import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Real, vector brand marks for the social sign-in buttons — rendered straight
/// from the official SVG logos so they're pixel-perfect at any size. Brand
/// colours are intentionally exempt from the app's single-accent rule: a Google
/// "G" only reads as real in its own four colours.

/// The multi-colour Google "G".
class GoogleLogo extends StatelessWidget {
  const GoogleLogo({super.key, this.size = 20});

  final double size;

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
        'assets/illustrations/logo_google.svg',
        width: size,
        height: size,
      );
}

/// The Facebook "f" roundel.
class FacebookLogo extends StatelessWidget {
  const FacebookLogo({super.key, this.size = 22});

  final double size;

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
        'assets/illustrations/logo_facebook.svg',
        width: size,
        height: size,
      );
}
