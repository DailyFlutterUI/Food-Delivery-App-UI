import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Renders a food photo from either a bundled asset (`assets/...`) or a
/// network URL. Real photography fills its frame with [BoxFit.cover].
class FoodImage extends StatelessWidget {
  const FoodImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;

  bool get _isNetwork => url.startsWith('http');

  @override
  Widget build(BuildContext context) {
    if (!_isNetwork) {
      return Image.asset(
        url,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stack) => _fallback(),
      );
    }
    return Image.network(
      url,
      fit: fit,
      width: width,
      height: height,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return SizedBox(
          width: width,
          height: height,
          child: const Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stack) => _fallback(),
    );
  }

  Widget _fallback() {
    return Container(
      width: width,
      height: height,
      color: AppColors.chip,
      alignment: Alignment.center,
      child: const Icon(Icons.fastfood_rounded,
          color: AppColors.textMuted, size: 32),
    );
  }
}
