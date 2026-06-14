import 'package:flutter/material.dart';

import '../models/food.dart';
import '../state/cart.dart';
import '../theme/app_theme.dart';
import '../widgets/food_cutout.dart';
import '../widgets/primary_button.dart';
import '../widgets/quantity_stepper.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.food});

  final Food food;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  int _quantity = 1;
  int _sizeIndex = 0;
  bool _favourite = false;

  @override
  Widget build(BuildContext context) {
    final food = widget.food;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _HeroAppBar(
                food: food,
                favourite: _favourite,
                onFavourite: () => setState(() => _favourite = !_favourite),
              ),
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -10),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(40), // increase this value
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 26, 24, 140),
                    child: _Body(
                      food: food,
                      sizeIndex: _sizeIndex,
                      onSize: (i) {
                        setState(() => _sizeIndex = i);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _BottomBar(
              food: food,
              quantity: _quantity,
              onIncrement: () => setState(() => _quantity++),
              onDecrement: () =>
                  setState(() => _quantity = _quantity > 1 ? _quantity - 1 : 1),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroAppBar extends StatelessWidget {
  const _HeroAppBar({
    required this.food,
    required this.favourite,
    required this.onFavourite,
  });

  final Food food;
  final bool favourite;
  final VoidCallback onFavourite;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 340,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leadingWidth: 70,
      leading: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: _GlassButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () => Navigator.of(context).maybePop(),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: _GlassButton(
            icon: favourite
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            iconColor: favourite ? AppColors.primary : AppColors.textPrimary,
            onTap: onFavourite,
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.accentSoft, AppColors.background],
                ),
              ),
            ),
            // Soft accent halo behind the floating dish.
            Center(
              child: Container(
                width: 280,
                height: 280,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.16),
                      AppColors.primary.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 24),
                child: FoodCutout(food: food, size: 240),
              ),
            ),
            if (food.isPopular)
              Positioned(
                left: 20,
                bottom: 44,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'POPULAR',
                        style: AppText.eyebrow.copyWith(
                          color: Colors.white,
                          fontSize: 9.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.food,
    required this.sizeIndex,
    required this.onSize,
  });

  final Food food;
  final int sizeIndex;
  final ValueChanged<int> onSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title + price
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(food.name, style: AppText.h1.copyWith(fontSize: 25)),
                  const SizedBox(height: 6),
                  Text(food.tagline, style: AppText.label),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Price', style: AppText.eyebrow),
                const SizedBox(height: 4),
                Text(
                  food.priceLabel,
                  style: AppText.price.copyWith(
                    fontSize: 24,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 18),
        // Quick stats
        Row(
          children: [
            _StatChip(
              icon: Icons.star_rounded,
              iconColor: AppColors.amber,
              label: '${food.rating}',
              sub: '${food.reviewCount} reviews',
            ),
            const SizedBox(width: 12),
            _StatChip(
              icon: Icons.access_time_rounded,
              label: '${food.deliveryMinutes} min',
              sub: 'Delivery',
            ),
            const SizedBox(width: 12),
            _StatChip(
              icon: Icons.local_fire_department_rounded,
              label: '${food.calories}',
              sub: 'Calories',
            ),
          ],
        ),
        const SizedBox(height: 26),
        // Size selector
        if (food.sizes.isNotEmpty) ...[
          const Text('CHOOSE SIZE', style: AppText.eyebrow),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < food.sizes.length; i++) ...[
                _SizeChip(
                  label: food.sizes[i],
                  selected: i == sizeIndex,
                  onTap: () => onSize(i),
                ),
                if (i != food.sizes.length - 1) const SizedBox(width: 10),
              ],
            ],
          ),
          const SizedBox(height: 26),
        ],
        // Ingredients
        if (food.ingredients.isNotEmpty) ...[
          const Text('INGREDIENTS', style: AppText.eyebrow),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: food.ingredients.length,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (context, i) =>
                  _IngredientChip(ingredient: food.ingredients[i]),
            ),
          ),
          const SizedBox(height: 26),
        ],
        // Description
        const Text('DESCRIPTION', style: AppText.eyebrow),
        const SizedBox(height: 10),
        Text(food.description, style: AppText.body),
        const SizedBox(height: 26),
        // Nutrition
        const Text('NUTRITION', style: AppText.eyebrow),
        const SizedBox(height: 12),
        _NutritionRow(calories: food.calories),
        const SizedBox(height: 26),
        // Reviews
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('REVIEWS', style: AppText.eyebrow),
            Text(
              'See all ${food.reviewCount}',
              style: AppText.label.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _RatingSummary(rating: food.rating, count: food.reviewCount),
        const SizedBox(height: 16),
        for (final review in food.reviews) ...[
          _ReviewCard(review: review),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.sub,
    this.iconColor = AppColors.primary,
  });

  final IconData icon;
  final String label;
  final String sub;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.hairline),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(height: 6),
            Text(label, style: AppText.title.copyWith(fontSize: 15)),
            const SizedBox(height: 2),
            Text(sub, style: AppText.label.copyWith(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _SizeChip extends StatelessWidget {
  const _SizeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.hairline,
          ),
        ),
        child: Text(
          label,
          style: AppText.label.copyWith(
            color: selected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _IngredientChip extends StatelessWidget {
  const _IngredientChip({required this.ingredient});

  final Ingredient ingredient;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.hairline),
          ),
          alignment: Alignment.center,
          child: Text(ingredient.icon, style: const TextStyle(fontSize: 24)),
        ),
        const SizedBox(height: 6),
        Text(ingredient.name, style: AppText.label.copyWith(fontSize: 11)),
      ],
    );
  }
}

class _NutritionRow extends StatelessWidget {
  const _NutritionRow({required this.calories});

  final int calories;

  @override
  Widget build(BuildContext context) {
    // Approximate macro split for display purposes.
    final protein = (calories * 0.20 / 4).round();
    final carbs = (calories * 0.45 / 4).round();
    final fat = (calories * 0.35 / 9).round();
    return Row(
      children: [
        _NutritionCard(label: 'Calories', value: '$calories', unit: 'kcal'),
        const SizedBox(width: 12),
        _NutritionCard(label: 'Protein', value: '$protein', unit: 'g'),
        const SizedBox(width: 12),
        _NutritionCard(label: 'Carbs', value: '$carbs', unit: 'g'),
        const SizedBox(width: 12),
        _NutritionCard(label: 'Fat', value: '$fat', unit: 'g'),
      ],
    );
  }
}

class _NutritionCard extends StatelessWidget {
  const _NutritionCard({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.accentSoft,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppText.price.copyWith(
                fontSize: 18,
                color: AppColors.primaryDark,
              ),
            ),
            Text(unit, style: AppText.label.copyWith(fontSize: 10)),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppText.label.copyWith(
                fontSize: 11,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingSummary extends StatelessWidget {
  const _RatingSummary({required this.rating, required this.count});

  final double rating;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text('$rating', style: AppText.display.copyWith(fontSize: 34)),
              Row(
                children: List.generate(5, (i) {
                  return Icon(
                    i < rating.floor()
                        ? Icons.star_rounded
                        : (i < rating
                              ? Icons.star_half_rounded
                              : Icons.star_outline_rounded),
                    size: 14,
                    color: AppColors.amber,
                  );
                }),
              ),
              const SizedBox(height: 4),
              Text(
                '$count reviews',
                style: AppText.label.copyWith(fontSize: 11),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              children: [
                for (final entry in const [
                  (5, 0.82),
                  (4, 0.12),
                  (3, 0.04),
                  (2, 0.01),
                  (1, 0.01),
                ])
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Text(
                          '${entry.$1}',
                          style: AppText.label.copyWith(fontSize: 11),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: entry.$2,
                              minHeight: 6,
                              backgroundColor: AppColors.surfaceAlt,
                              valueColor: const AlwaysStoppedAnimation(
                                AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceAlt,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  review.avatar,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.name,
                      style: AppText.title.copyWith(fontSize: 14),
                    ),
                    Text(
                      review.timeAgo,
                      style: AppText.label.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentSoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 13,
                      color: AppColors.amber,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${review.rating}',
                      style: AppText.label.copyWith(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(review.comment, style: AppText.body),
        ],
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({
    required this.icon,
    required this.onTap,
    this.iconColor = AppColors.textPrimary,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: Colors.black26,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 18, color: iconColor),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.food,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  final Food food;
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final total = food.price * quantity;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
        boxShadow: AppShadows.floating,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            QuantityStepper(
              quantity: quantity,
              onIncrement: onIncrement,
              onDecrement: onDecrement,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: PrimaryButton(
                label: 'Add  ·  \$${total.toStringAsFixed(2)}',
                icon: Icons.shopping_bag_outlined,
                onPressed: () {
                  Cart.instance.add(food, quantity: quantity);
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: AppColors.textPrimary,
                        content: Text(
                          '${food.name} added to cart',
                          style: const TextStyle(fontFamily: AppTheme.bodyFont),
                        ),
                      ),
                    );
                  Navigator.of(context).maybePop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
