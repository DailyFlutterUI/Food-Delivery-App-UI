import 'package:flutter/material.dart';

import 'delivery_theme.dart';

/// The six stages of a delivery, in order.
enum Stage { confirmed, packed, assigned, onTheWay, near, delivered }

/// Static metadata for each stage — the copy and iconography shown in the
/// timeline and the status panel.
class StageInfo {
  const StageInfo({
    required this.emoji,
    required this.title,
    required this.status,
    required this.line,
    required this.icon,
    required this.etaMinutes,
  });

  final String emoji;
  final String title;
  final String status; // short word for the status pill
  final String line; // short status line
  final IconData icon;
  final int etaMinutes; // ETA shown while at this stage

  static const Map<Stage, StageInfo> all = {
    Stage.confirmed: StageInfo(
      emoji: '📦',
      title: 'Order Confirmed',
      status: 'Confirmed',
      line: 'We received your order',
      icon: Icons.receipt_long_rounded,
      etaMinutes: 95,
    ),
    Stage.packed: StageInfo(
      emoji: '🏭',
      title: 'Packed at Warehouse',
      status: 'Packed',
      line: 'Scanned and ready to ship',
      icon: Icons.inventory_2_rounded,
      etaMinutes: 78,
    ),
    Stage.assigned: StageInfo(
      emoji: '🚚',
      title: 'Driver Assigned',
      status: 'Assigned',
      line: 'Khalid is picking up your parcel',
      icon: Icons.person_pin_circle_rounded,
      etaMinutes: 54,
    ),
    Stage.onTheWay: StageInfo(
      emoji: '🚚',
      title: 'On the Way',
      status: 'Transit',
      line: 'Your parcel is moving toward you',
      icon: Icons.local_shipping_rounded,
      etaMinutes: 22,
    ),
    Stage.near: StageInfo(
      emoji: '⚡',
      title: 'Near Destination',
      status: 'Arriving',
      line: 'Almost there — arriving any minute',
      icon: Icons.bolt_rounded,
      etaMinutes: 3,
    ),
    Stage.delivered: StageInfo(
      emoji: '✅',
      title: 'Delivered',
      status: 'Delivered',
      line: 'Left at your front door',
      icon: Icons.check_circle_rounded,
      etaMinutes: 0,
    ),
  };

  static StageInfo of(Stage s) => all[s]!;
}

/// Holds the live state of the tracked order: which stage it's at, plus a
/// little order metadata. A plain [ChangeNotifier] singleton — sufficient for
/// this single-order demo.
class DeliveryStore extends ChangeNotifier {
  int _index = 0;

  // Fixed order metadata for the header and the detail sheet.
  final String orderId = 'H314315796';
  final String item = 'Mac Mini M4 Pro';
  final String fromCity = 'Diriyah, Riyadh';
  final String toCity = 'Jawhra, Jeddah';
  final String createdDate = '18 Oct 2025';
  final String estDate = '19 Oct 2025';
  final String customer = 'Ahmad Kawsar';
  final String cost = r'$120.00';
  final String quantity = '1 Box';
  final String weight = '10 Kg';
  final String courier = 'DailyFlutterUI';
  final String courierRole = 'Courier';
  final String courierAvatar = 'https://i.pravatar.cc/200?img=68';

  Stage get stage => Stage.values[_index];
  int get index => _index;
  bool get isFirst => _index == 0;
  bool get isLast => _index == Stage.values.length - 1;
  StageInfo get info => StageInfo.of(stage);

  /// Progress through the whole journey, 0..1.
  double get journey => _index / (Stage.values.length - 1);

  bool isComplete(Stage s) => s.index < _index;
  bool isCurrent(Stage s) => s.index == _index;

  void advance() {
    if (isLast) return;
    _index++;
    notifyListeners();
  }

  void reset() {
    _index = 0;
    notifyListeners();
  }
}

final deliveryStore = DeliveryStore();

/// The palette is monochrome + a single orange, so every stage shares the
/// accent. Kept as a helper so call sites read intentionally.
Color stageAccent(Stage s) => D.accent;
