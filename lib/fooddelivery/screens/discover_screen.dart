import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../data/foods.dart';
import '../models/food.dart';
import '../state/cart.dart';
import '../theme/app_theme.dart';
import '../widgets/food_image.dart';
import 'detail_screen.dart';

/// An immersive, motion-rich way to browse dishes, built around transparent
/// food cutouts that actually *float*.
///
/// Three layered motions drive the feel:
///  1. **Entrance** — each dish tumbles up from below in a stagger (3D rotate +
///     overshoot scale), while a soft accent glow drifts up behind the list.
///  2. **Idle float** — the cutout gently bobs and tilts forever, so it reads
///     as hovering above its card rather than pasted on.
///  3. **Scroll depth** — the focal dish (near the top) is large and sharp;
///     dishes below recede in 3D — scaled down, blurred, faded — and the
///     floating food parallaxes against its card for real depth.
///
/// Scrolling snaps one dish at a time to the focal line, and a dot rail on the
/// right marks which dish is current.
class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key, this.foods});

  /// Defaults to the full menu when no explicit list is passed.
  final List<Food>? foods;

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen>
    with TickerProviderStateMixin {
  late final ScrollController _scroll;
  late final AnimationController _entrance;
  late final AnimationController _float;

  /// One card + the gap beneath it. Cards snap to this rhythm so the depth
  /// maths can locate every row without measuring it.
  static const double _cardHeight = 384;
  static const double _gap = 26;
  static const double _itemExtent = _cardHeight + _gap;

  /// Small gap above the first card; the focal line sits just below it so the
  /// first dish is sharp at rest — no large blank band up top.
  static const double _topPad = 16;

  List<Food> get _foods => widget.foods ?? kFoods;

  @override
  void initState() {
    super.initState();
    _scroll = ScrollController();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _float = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _scroll.dispose();
    _entrance.dispose();
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(count: _foods.length),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final viewportHeight = constraints.maxHeight;
                  final focalY = _topPad + _cardHeight / 2;
                  // Enough tail room that the last dish can still reach focal.
                  final bottomPad = (viewportHeight - _cardHeight - _topPad)
                      .clamp(24.0, double.infinity);
                  return Stack(
                    children: [
                      _AmbientGlow(animation: _entrance),
                      ListView.builder(
                        controller: _scroll,
                        physics: const _SnapPhysics(
                          parent: BouncingScrollPhysics(),
                          itemExtent: _itemExtent,
                        ),
                        padding: EdgeInsets.fromLTRB(24, _topPad, 24, bottomPad),
                        itemExtent: _itemExtent,
                        itemCount: _foods.length,
                        itemBuilder: (context, i) => _DepthCard(
                          food: _foods[i],
                          index: i,
                          scroll: _scroll,
                          entrance: _entrance,
                          float: _float,
                          cardHeight: _cardHeight,
                          itemExtent: _itemExtent,
                          topPadding: _topPad,
                          focalY: focalY,
                          viewportHeight: viewportHeight,
                        ),
                      ),
                      _DotsRail(
                        scroll: _scroll,
                        count: _foods.length,
                        itemExtent: _itemExtent,
                      ),
                    ],
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

/// A single dish card. Owns the entrance tumble, the scroll-depth pose of the
/// whole card, and the floating/parallaxing cutout inside it. Rebuilds against
/// scroll + entrance + float so every layer updates per frame.
class _DepthCard extends StatelessWidget {
  const _DepthCard({
    required this.food,
    required this.index,
    required this.scroll,
    required this.entrance,
    required this.float,
    required this.cardHeight,
    required this.itemExtent,
    required this.topPadding,
    required this.focalY,
    required this.viewportHeight,
  });

  final Food food;
  final int index;
  final ScrollController scroll;
  final AnimationController entrance;
  final AnimationController float;
  final double cardHeight;
  final double itemExtent;
  final double topPadding;
  final double focalY;
  final double viewportHeight;

  @override
  Widget build(BuildContext context) {
    // Stagger: each card starts a touch later, then overshoots (easeOutBack).
    final start = (index * 0.08).clamp(0.0, 0.55);
    final entranceAnim = CurvedAnimation(
      parent: entrance,
      curve: Interval(start, (start + 0.55).clamp(0.0, 1.0),
          curve: Curves.easeOutBack),
    );

    return AnimatedBuilder(
      animation: Listenable.merge([scroll, entrance, float]),
      builder: (context, child) {
        // --- Scroll depth (whole card) -----------------------------------
        final offset = scroll.hasClients ? scroll.offset : 0.0;
        final cardTop = topPadding + index * itemExtent - offset;
        final cardCenter = cardTop + cardHeight / 2;
        // Signed distance from the focal line, normalised by viewport.
        final delta =
            ((cardCenter - focalY) / viewportHeight).clamp(-1.2, 1.2);
        final dist = delta.abs().clamp(0.0, 1.0);

        final scale = 1 - dist * 0.18; // 1.0 focal → 0.82 at the edges
        final blur = dist * dist * 4.5; // sharp through the middle
        final depthFade = 1 - dist * 0.40;
        final tilt = delta * 0.40; // card leans away in 3D

        // --- Entrance (whole card lifts in) ------------------------------
        final e = entranceAnim.value; // overshoots past 1.0, then settles
        final enterFade = e.clamp(0.0, 1.0);
        final enterY = (1 - e) * 90;
        final landed = enterFade * (1 - dist); // shadow strength

        final cardMatrix = Matrix4.identity()
          ..setEntry(3, 2, 0.0011)
          ..rotateX(tilt)
          ..scaleByDouble(scale, scale, scale, 1);

        // --- Idle float + parallax of the cutout -------------------------
        final phase = index * 0.37;
        final bob = math.sin((float.value * 2 * math.pi) + phase);
        final floatY = bob * 7.0 - delta * 26.0; // hover + scroll parallax
        final floatTilt = bob * 0.05; // gentle 3D wobble

        // Cutout entrance: flies from further below with a rotate + pop.
        final foodEnterY = (1 - e) * 150;
        final foodRotZ = (1 - e) * 0.45 + floatTilt * 0.5;
        final foodScale = 0.7 + e * 0.3;

        return Transform.translate(
          offset: Offset(0, enterY),
          child: Opacity(
            opacity: (enterFade * depthFade).clamp(0.0, 1.0),
            child: Transform(
              alignment: Alignment.center,
              transform: cardMatrix,
              child: _CardSurface(
                food: food,
                cardHeight: cardHeight,
                elevation: landed,
                blur: blur,
                floatY: floatY,
                foodEnterY: foodEnterY,
                foodRotZ: foodRotZ,
                foodTiltX: floatTilt,
                foodScale: foodScale,
                liftShadow: (landed * (1 - bob.abs() * 0.3)).clamp(0.0, 1.0),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// The visible card: a clean light surface with the food cutout floating above
/// a soft contact shadow, and a caption block beneath. [blur] applies the
/// depth defocus for off-centre cards.
class _CardSurface extends StatelessWidget {
  const _CardSurface({
    required this.food,
    required this.cardHeight,
    required this.elevation,
    required this.blur,
    required this.floatY,
    required this.foodEnterY,
    required this.foodRotZ,
    required this.foodTiltX,
    required this.foodScale,
    required this.liftShadow,
  });

  final Food food;
  final double cardHeight;
  final double elevation;
  final double blur;
  final double floatY;
  final double foodEnterY;
  final double foodRotZ;
  final double foodTiltX;
  final double foodScale;
  final double liftShadow;

  @override
  Widget build(BuildContext context) {
    final deal = _dealFor(food);
    final foodMatrix = Matrix4.identity()
      ..setEntry(3, 2, 0.0016)
      ..rotateX(foodTiltX)
      ..rotateZ(foodRotZ)
      ..scaleByDouble(foodScale, foodScale, foodScale, 1);

    Widget surface = Container(
      height: cardHeight,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, AppColors.surfaceAlt],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.hairline),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF14102A)
                .withValues(alpha: 0.05 + elevation * 0.14),
            blurRadius: 24 + elevation * 34,
            offset: Offset(0, 14 + elevation * 20),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Quiet accent halo behind the food — single accent, low opacity.
          Positioned(
            top: 18,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 230,
                height: 230,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.12),
                      AppColors.primary.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Pills: rating (left) and delivery time (right).
          Positioned(
            top: 18,
            left: 18,
            child: _Pill(
              icon: Icons.star_rounded,
              iconColor: AppColors.amber,
              label: '${food.rating}',
            ),
          ),
          Positioned(
            top: 18,
            right: 18,
            child: _Pill(
              icon: Icons.schedule_rounded,
              iconColor: AppColors.textSecondary,
              label: '${food.deliveryMinutes} min',
            ),
          ),
          // Deal / bestseller badge — the eye-catcher.
          if (deal != null)
            Positioned(
              top: 18,
              left: 0,
              right: 0,
              child: Center(child: _DealBadge(percent: deal.percent)),
            ),
          // Floating cutout + its contact shadow.
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 210,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Contact shadow on the surface — shrinks as the food lifts.
                  Positioned(
                    bottom: 6,
                    child: Transform.translate(
                      offset: Offset(0, -floatY * 0.15),
                      child: Opacity(
                        opacity: (0.22 * liftShadow).clamp(0.0, 0.22),
                        child: Container(
                          width: 150 - floatY.abs() * 1.2,
                          height: 26,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [Color(0xFF14102A), Color(0x0014102A)],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // The food itself.
                  Transform.translate(
                    offset: Offset(0, floatY + foodEnterY),
                    child: Transform(
                      alignment: Alignment.center,
                      transform: foodMatrix,
                      child: food.cutoutUrl.isNotEmpty
                          ? Image.asset(food.cutoutUrl,
                              width: 188, height: 188, fit: BoxFit.contain)
                          : SizedBox(
                              width: 188,
                              height: 188,
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.lg),
                                child: FoodImage(url: food.imageUrl),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Caption block.
          Positioned(
            left: 22,
            right: 22,
            bottom: 22,
            child: _Caption(food: food, deal: deal),
          ),
        ],
      ),
    );

    if (blur > 0.25) {
      surface = ImageFiltered(
        imageFilter: ImageFilter.blur(
          sigmaX: blur,
          sigmaY: blur,
          tileMode: TileMode.decal,
        ),
        child: surface,
      );
    }

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => DetailScreen(food: food)),
      ),
      child: surface,
    );
  }
}

/// A simple percentage deal derived from the dish — no data-model change.
/// Bestsellers get a discount so the Discover feed reads as "limited offers".
typedef _Deal = ({int percent, double original});

_Deal? _dealFor(Food food) {
  if (!food.isPopular) return null;
  const options = [20, 25, 30];
  final percent = options[food.name.length % options.length];
  final original = food.price / (1 - percent / 100);
  return (percent: percent, original: original);
}

class _Caption extends StatelessWidget {
  const _Caption({required this.food, required this.deal});

  final Food food;
  final _Deal? deal;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(food.tagline.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.eyebrow),
        const SizedBox(height: 7),
        Text(food.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.h1),
        const SizedBox(height: 8),
        // Social proof — urgency line driven by the dish's review count.
        Row(
          children: [
            const Icon(Icons.local_fire_department_rounded,
                size: 15, color: AppColors.primary),
            const SizedBox(width: 4),
            Text('${food.reviewCount} ordered this week',
                style: AppText.label.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                )),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(food.priceLabel, style: AppText.price.copyWith(fontSize: 22)),
            if (deal != null) ...[
              const SizedBox(width: 8),
              Text('\$${deal!.original.toStringAsFixed(2)}',
                  style: AppText.label.copyWith(
                    color: AppColors.textMuted,
                    decoration: TextDecoration.lineThrough,
                    fontSize: 13,
                  )),
            ],
            const Spacer(),
            _AddButton(food: food),
          ],
        ),
      ],
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.food});

  final Food food;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(30);
    return Material(
      color: AppColors.primary,
      borderRadius: radius,
      elevation: 6,
      shadowColor: AppColors.primary.withValues(alpha: 0.5),
      child: InkWell(
        borderRadius: radius,
        onTap: () {
          Cart.instance.add(food);
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.textPrimary,
                duration: const Duration(milliseconds: 1200),
                content: Text('${food.name} added to cart',
                    style: AppText.label.copyWith(color: Colors.white)),
              ),
            );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_rounded, size: 18, color: Colors.white),
              const SizedBox(width: 6),
              Text('Add', style: AppText.button.copyWith(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}

/// A discount pill — draws the eye to the offer.
class _DealBadge extends StatelessWidget {
  const _DealBadge({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(20),
      elevation: 4,
      shadowColor: AppColors.primary.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bolt_rounded, size: 14, color: Colors.white),
            const SizedBox(width: 3),
            Text('SAVE $percent%',
                style: AppText.eyebrow.copyWith(
                  color: Colors.white,
                  fontSize: 10.5,
                  letterSpacing: 0.6,
                )),
          ],
        ),
      ),
    );
  }
}

/// Vertical position indicator on the right edge — the elongated accent dot
/// marks the dish currently at the focal line.
class _DotsRail extends StatelessWidget {
  const _DotsRail({
    required this.scroll,
    required this.count,
    required this.itemExtent,
  });

  final ScrollController scroll;
  final int count;
  final double itemExtent;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 8,
      top: 0,
      bottom: 0,
      child: Center(
        child: AnimatedBuilder(
          animation: scroll,
          builder: (context, _) {
            final offset = scroll.hasClients ? scroll.offset : 0.0;
            final active = (offset / itemExtent).round().clamp(0, count - 1);
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < count; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.symmetric(vertical: 3.5),
                    width: 6,
                    height: i == active ? 20 : 6,
                    decoration: BoxDecoration(
                      color: i == active
                          ? AppColors.primary
                          : AppColors.textMuted.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Snaps the list so exactly one dish settles on the focal line per fling or
/// drag-release — makes "which dish is current" unambiguous.
class _SnapPhysics extends ScrollPhysics {
  const _SnapPhysics({super.parent, required this.itemExtent});

  final double itemExtent;

  @override
  _SnapPhysics applyTo(ScrollPhysics? ancestor) =>
      _SnapPhysics(parent: buildParent(ancestor), itemExtent: itemExtent);

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    final tol = toleranceFor(position);
    // Let the edges bounce naturally.
    if ((velocity <= 0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }
    var page = position.pixels / itemExtent;
    if (velocity < -tol.velocity) {
      page -= 0.5;
    } else if (velocity > tol.velocity) {
      page += 0.5;
    }
    final target = (page.roundToDouble() * itemExtent)
        .clamp(position.minScrollExtent, position.maxScrollExtent);
    if ((target - position.pixels).abs() < tol.distance) return null;
    return ScrollSpringSimulation(spring, position.pixels, target, velocity,
        tolerance: tol);
  }

  @override
  bool get allowImplicitScrolling => false;
}

/// A soft accent glow that drifts upward and fades in alongside the entrance,
/// giving the background a quiet shift in depth. Restrained — single accent.
class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = Curves.easeOut.transform(animation.value);
        return Positioned.fill(
          child: IgnorePointer(
            child: Align(
              alignment: Alignment(0, 0.85 - t * 0.5),
              child: Opacity(
                opacity: 0.5 * t,
                child: Container(
                  width: 360,
                  height: 360,
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
            ),
          ),
        );
      },
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 4),
          Text(label,
              style: AppText.label.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              )),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Row(
        children: [
          Material(
            color: Colors.white,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => Navigator.of(context).maybePop(),
              child: Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.hairline),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 18, color: AppColors.textPrimary),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Discover', style: AppText.h1),
              Text('$count dishes · swipe through', style: AppText.label),
            ],
          ),
        ],
      ),
    );
  }
}
