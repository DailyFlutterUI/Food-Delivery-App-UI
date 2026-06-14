import 'package:flutter/foundation.dart';

import '../models/food.dart';

/// App-wide cart. Simple [ChangeNotifier] singleton so any screen can listen
/// with a [ListenableBuilder] without pulling in a state-management package.
class Cart extends ChangeNotifier {
  Cart._();
  static final Cart instance = Cart._();

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get count => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0, (sum, item) => sum + item.total);

  CartItem? _find(String foodId) {
    for (final item in _items) {
      if (item.food.id == foodId) return item;
    }
    return null;
  }

  int quantityOf(String foodId) => _find(foodId)?.quantity ?? 0;

  void add(Food food, {int quantity = 1}) {
    final existing = _find(food.id);
    if (existing != null) {
      existing.quantity += quantity;
    } else {
      _items.add(CartItem(food: food, quantity: quantity));
    }
    notifyListeners();
  }

  void increment(String foodId) {
    final item = _find(foodId);
    if (item != null) {
      item.quantity++;
      notifyListeners();
    }
  }

  void decrement(String foodId) {
    final item = _find(foodId);
    if (item == null) return;
    item.quantity--;
    if (item.quantity <= 0) _items.remove(item);
    notifyListeners();
  }

  void remove(String foodId) {
    _items.removeWhere((item) => item.food.id == foodId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
