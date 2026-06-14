import 'package:flutter/foundation.dart';

enum FoodCategory { all, burger, hotdog, sushi, salad, sides }

extension FoodCategoryLabel on FoodCategory {
  String get label {
    switch (this) {
      case FoodCategory.all:
        return 'All';
      case FoodCategory.burger:
        return 'Burger';
      case FoodCategory.hotdog:
        return 'Hotdog';
      case FoodCategory.sushi:
        return 'Sushi';
      case FoodCategory.salad:
        return 'Salad';
      case FoodCategory.sides:
        return 'Sides';
    }
  }
}

/// A choosable ingredient / add-on shown on the detail page.
@immutable
class Ingredient {
  const Ingredient(this.name, this.icon);
  final String name;
  final String icon; // emoji glyph
}

/// A single customer review.
@immutable
class Review {
  const Review({
    required this.name,
    required this.rating,
    required this.comment,
    required this.timeAgo,
    required this.avatar,
  });

  final String name;
  final double rating;
  final String comment;
  final String timeAgo;
  final String avatar; // emoji avatar
}

@immutable
class Food {
  const Food({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.cutoutUrl = '',
    required this.category,
    this.rating = 4.5,
    this.reviewCount = 120,
    this.deliveryMinutes = 15,
    this.distanceKm = 1.6,
    this.calories = 540,
    this.sizes = const ['Regular', 'Large'],
    this.ingredients = const [],
    this.reviews = const [],
    this.isPopular = false,
  });

  final String id;
  final String name;
  final String tagline; // short one-liner under the name
  final String description;
  final double price;
  final String imageUrl;

  /// Transparent-background PNG (Fluent 3D) used for the floating "flying"
  /// treatment on the Discover screen. Falls back to nothing when empty.
  final String cutoutUrl;
  final FoodCategory category;
  final double rating;
  final int reviewCount;
  final int deliveryMinutes;
  final double distanceKm;
  final int calories;
  final List<String> sizes;
  final List<Ingredient> ingredients;
  final List<Review> reviews;
  final bool isPopular;

  String get priceLabel => '\$${price.toStringAsFixed(2)}';
}

/// A single line in the cart.
class CartItem {
  CartItem({required this.food, this.quantity = 1, this.size});

  final Food food;
  int quantity;
  final String? size;

  double get total => food.price * quantity;
}
