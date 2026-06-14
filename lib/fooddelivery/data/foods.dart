import '../models/food.dart';

/// Premium sample menu backed by real food photography under `assets/images/`.
const List<Food> kFoods = [
  Food(
    id: 'deluxe_burger',
    name: 'Double Deluxe Burger',
    tagline: 'Signature · House special',
    description:
        'Two flame-grilled beef patties stacked with aged cheddar, smoked bacon, '
        'caramelised onions and our secret house sauce in a toasted brioche bun.',
    price: 18.90,
    imageUrl: 'assets/images/food_deluxe_burger.jpg',
    cutoutUrl: 'assets/images/cutout_burger.png',
    category: FoodCategory.burger,
    rating: 4.9,
    reviewCount: 482,
    deliveryMinutes: 20,
    distanceKm: 1.2,
    calories: 780,
    sizes: ['Single', 'Double', 'Triple'],
    ingredients: [
      Ingredient('Beef', '🥩'),
      Ingredient('Cheddar', '🧀'),
      Ingredient('Bacon', '🥓'),
      Ingredient('Onion', '🧅'),
      Ingredient('Brioche', '🍞'),
    ],
    reviews: [
      Review(
        name: 'Sarah Lim',
        rating: 5,
        comment: 'Honestly the best burger I’ve had delivered. Still warm and juicy!',
        timeAgo: '2 days ago',
        avatar: '👩🏻',
      ),
      Review(
        name: 'Marcus Tan',
        rating: 4.5,
        comment: 'Generous portions and the sauce is incredible. Will reorder.',
        timeAgo: '5 days ago',
        avatar: '🧑🏽',
      ),
    ],
    isPopular: true,
  ),
  Food(
    id: 'salmon_sushi',
    name: 'Salmon Sushi Set',
    tagline: 'Chef’s selection · Fresh daily',
    description:
        'A curated set of salmon nigiri and signature rolls prepared with sushi-grade '
        'salmon, served with wasabi, pickled ginger and house soy.',
    price: 24.50,
    imageUrl: 'assets/images/food_sushi.jpg',
    cutoutUrl: 'assets/images/cutout_sushi.png',
    category: FoodCategory.sushi,
    rating: 4.8,
    reviewCount: 311,
    deliveryMinutes: 18,
    distanceKm: 2.1,
    calories: 420,
    sizes: ['8 pcs', '12 pcs', '16 pcs'],
    ingredients: [
      Ingredient('Salmon', '🐟'),
      Ingredient('Rice', '🍚'),
      Ingredient('Nori', '🍙'),
      Ingredient('Avocado', '🥑'),
      Ingredient('Wasabi', '🌿'),
    ],
    reviews: [
      Review(
        name: 'Aiko Mori',
        rating: 5,
        comment: 'Tasted incredibly fresh. Beautifully presented too.',
        timeAgo: '1 day ago',
        avatar: '👩🏻',
      ),
    ],
    isPopular: true,
  ),
  Food(
    id: 'truffle_fries',
    name: 'Truffle Loaded Fries',
    tagline: 'Crispy · Shareable',
    description:
        'Golden hand-cut fries tossed in truffle oil, topped with parmesan, '
        'fresh herbs and a creamy garlic aioli on the side.',
    price: 9.90,
    imageUrl: 'assets/images/food_fries.jpg',
    cutoutUrl: 'assets/images/cutout_fries.png',
    category: FoodCategory.sides,
    rating: 4.7,
    reviewCount: 268,
    deliveryMinutes: 12,
    distanceKm: 1.6,
    calories: 510,
    sizes: ['Regular', 'Large', 'Sharing'],
    ingredients: [
      Ingredient('Potato', '🥔'),
      Ingredient('Truffle', '🍄'),
      Ingredient('Parmesan', '🧀'),
      Ingredient('Aioli', '🥣'),
    ],
    reviews: [
      Review(
        name: 'Diego Cruz',
        rating: 4.5,
        comment: 'Addictive. The truffle aroma hits before you even open the box.',
        timeAgo: '3 days ago',
        avatar: '🧑🏽',
      ),
    ],
    isPopular: true,
  ),
  Food(
    id: 'cheeseburger',
    name: 'Classic Cheeseburger',
    tagline: 'All-time favourite',
    description:
        'A juicy char-grilled beef patty with melted American cheese, crisp lettuce, '
        'tomato and pickles in a soft sesame bun.',
    price: 12.50,
    imageUrl: 'assets/images/food_cheeseburger.jpg',
    cutoutUrl: 'assets/images/cutout_burger.png',
    category: FoodCategory.burger,
    rating: 4.6,
    reviewCount: 540,
    deliveryMinutes: 18,
    distanceKm: 1.4,
    calories: 620,
    sizes: ['Single', 'Double'],
    ingredients: [
      Ingredient('Beef', '🥩'),
      Ingredient('Cheese', '🧀'),
      Ingredient('Lettuce', '🥬'),
      Ingredient('Tomato', '🍅'),
    ],
    reviews: [
      Review(
        name: 'Emma Stone',
        rating: 4.5,
        comment: 'Simple, classic and done right. Exactly what I wanted.',
        timeAgo: '6 days ago',
        avatar: '👩🏼',
      ),
    ],
  ),
  Food(
    id: 'gourmet_hotdog',
    name: 'Gourmet Hotdog',
    tagline: 'Street-style · Loaded',
    description:
        'A premium pork sausage in a brioche roll, topped with fresh herbs, '
        'crispy onions and a drizzle of mustard and ketchup.',
    price: 8.50,
    imageUrl: 'assets/images/food_hotdog.jpg',
    cutoutUrl: 'assets/images/cutout_hotdog.png',
    category: FoodCategory.hotdog,
    rating: 4.5,
    reviewCount: 196,
    deliveryMinutes: 14,
    distanceKm: 1.9,
    calories: 480,
    sizes: ['Regular', 'Footlong'],
    ingredients: [
      Ingredient('Sausage', '🌭'),
      Ingredient('Brioche', '🍞'),
      Ingredient('Herbs', '🌿'),
      Ingredient('Mustard', '🟡'),
    ],
    reviews: [
      Review(
        name: 'Liam Park',
        rating: 4.5,
        comment: 'Loved the brioche bun — elevates the whole thing.',
        timeAgo: '4 days ago',
        avatar: '🧑🏻',
      ),
    ],
  ),
  Food(
    id: 'sushi_platter',
    name: 'Dragon Roll Platter',
    tagline: 'Shareable · Premium',
    description:
        'An assortment of dragon rolls, maki and nigiri arranged on a sharing board '
        'with edamame, pickled vegetables and dipping sauces.',
    price: 32.00,
    imageUrl: 'assets/images/food_sushi_platter.jpg',
    cutoutUrl: 'assets/images/cutout_bento.png',
    category: FoodCategory.sushi,
    rating: 4.9,
    reviewCount: 142,
    deliveryMinutes: 22,
    distanceKm: 2.3,
    calories: 690,
    sizes: ['For 2', 'For 4'],
    ingredients: [
      Ingredient('Salmon', '🐟'),
      Ingredient('Tuna', '🍣'),
      Ingredient('Avocado', '🥑'),
      Ingredient('Edamame', '🫛'),
    ],
    reviews: [
      Review(
        name: 'Nadia Rahman',
        rating: 5,
        comment: 'Perfect for date night. Looks stunning and tastes even better.',
        timeAgo: '1 week ago',
        avatar: '👩🏽',
      ),
    ],
  ),
  Food(
    id: 'caesar_salad',
    name: 'Grilled Caesar Salad',
    tagline: 'Fresh · Light',
    description:
        'Crisp romaine and baby gem tossed in classic Caesar dressing with parmesan, '
        'croutons and tender grilled chicken.',
    price: 11.00,
    imageUrl: 'assets/images/food_salad.jpg',
    cutoutUrl: 'assets/images/cutout_salad.png',
    category: FoodCategory.salad,
    rating: 4.4,
    reviewCount: 88,
    deliveryMinutes: 13,
    distanceKm: 1.2,
    calories: 320,
    sizes: ['Regular', 'Large'],
    ingredients: [
      Ingredient('Romaine', '🥬'),
      Ingredient('Chicken', '🍗'),
      Ingredient('Parmesan', '🧀'),
      Ingredient('Crouton', '🍞'),
    ],
    reviews: [
      Review(
        name: 'Olivia Chen',
        rating: 4.5,
        comment: 'Fresh and generous. The chicken was perfectly grilled.',
        timeAgo: '2 days ago',
        avatar: '👩🏻',
      ),
    ],
  ),
  Food(
    id: 'garden_burger',
    name: 'Garden Stack Burger',
    tagline: 'Fresh greens · Juicy',
    description:
        'A beef patty layered with melted mozzarella, fresh tomato, crisp lettuce '
        'and onion in a golden sesame bun.',
    price: 13.90,
    imageUrl: 'assets/images/food_garden_burger.jpg',
    cutoutUrl: 'assets/images/cutout_burger.png',
    category: FoodCategory.burger,
    rating: 4.6,
    reviewCount: 173,
    deliveryMinutes: 17,
    distanceKm: 1.5,
    calories: 650,
    sizes: ['Single', 'Double'],
    ingredients: [
      Ingredient('Beef', '🥩'),
      Ingredient('Mozzarella', '🧀'),
      Ingredient('Tomato', '🍅'),
      Ingredient('Lettuce', '🥬'),
    ],
    reviews: [
      Review(
        name: 'Noah Kim',
        rating: 4.5,
        comment: 'Really fresh tasting, not greasy at all. Great balance.',
        timeAgo: '5 days ago',
        avatar: '🧑🏻',
      ),
    ],
  ),
];

List<Food> get kPopularFoods =>
    kFoods.where((f) => f.isPopular).toList();

Food foodById(String id) => kFoods.firstWhere((f) => f.id == id);
