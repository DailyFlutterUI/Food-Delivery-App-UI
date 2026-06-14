import 'package:flutter/material.dart';

import '../data/foods.dart';
import '../models/food.dart';
import '../state/cart.dart';
import '../theme/app_theme.dart';
import '../widgets/food_cutout.dart';
import '../widgets/quantity_stepper.dart';

/// Scrollable list of menu items, each with a quantity stepper bound to the
/// shared [Cart].
class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Row(
                children: [
                  _BackButton(onTap: () => Navigator.of(context).maybePop()),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Our Menu', style: AppText.h2),
                      Text('${kFoods.length} dishes available',
                          style: AppText.label),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListenableBuilder(
                listenable: Cart.instance,
                builder: (context, _) {
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
                    itemCount: kFoods.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (context, i) => _MenuTile(food: kFoods[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.food});

  final Food food;

  @override
  Widget build(BuildContext context) {
    final cart = Cart.instance;
    final qty = cart.quantityOf(food.id);
    final selected = qty > 0;

    return GestureDetector(
      onTap: null,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.hairline,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            CutoutThumb(food: food, size: 72),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(food.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.title),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 14, color: AppColors.amber),
                      const SizedBox(width: 3),
                      Text('${food.rating}  ·  ${food.deliveryMinutes} min',
                          style: AppText.label),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(food.priceLabel,
                      style: AppText.price.copyWith(fontSize: 16)),
                ],
              ),
            ),
            if (selected)
              QuantityStepper(
                quantity: qty,
                onIncrement: () => cart.increment(food.id),
                onDecrement: () => cart.decrement(food.id),
              )
            else
              Material(
                color: AppColors.primary,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => cart.add(food),
                  child: const Padding(
                    padding: EdgeInsets.all(9),
                    child:
                        Icon(Icons.add_rounded, size: 18, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.hairline),
          ),
          child: Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
