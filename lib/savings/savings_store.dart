import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A single deposit — one moment of rain.
class Deposit {
  Deposit({required this.amount, required this.at});

  final double amount;
  final DateTime at;

  Map<String, dynamic> toJson() =>
      {'amount': amount, 'at': at.millisecondsSinceEpoch};

  factory Deposit.fromJson(Map<String, dynamic> j) => Deposit(
        amount: (j['amount'] as num).toDouble(),
        at: DateTime.fromMillisecondsSinceEpoch(j['at'] as int),
      );
}

/// The milestones (as fractions of the goal) that trigger a golden-rain burst.
const List<double> kMilestones = [0.25, 0.50, 0.75, 1.0];

/// Savings state backed by [SharedPreferences]: a single goal (name + target),
/// a running balance and the deposit history. Call [load] once at startup.
class SavingsStore extends ChangeNotifier {
  static const _kGoalName = 'mr_goal_name';
  static const _kTarget = 'mr_target';
  static const _kBalance = 'mr_balance';
  static const _kDeposits = 'mr_deposits';

  String _goalName = 'Dream Getaway';
  double _target = 5000;
  double _balance = 0;
  final List<Deposit> _deposits = [];
  bool _loaded = false;

  bool get loaded => _loaded;
  String get goalName => _goalName;
  double get target => _target;
  double get balance => _balance;
  double get remaining => (_target - _balance).clamp(0, double.infinity);
  double get progress => _target <= 0 ? 0 : (_balance / _target).clamp(0.0, 1.0);
  bool get reachedGoal => _balance >= _target && _target > 0;
  List<Deposit> get deposits => List.unmodifiable(_deposits);
  int get depositCount => _deposits.length;

  /// The highest milestone fraction already crossed by the current balance.
  double get _milestoneFor => kMilestones
      .where((m) => progress >= m)
      .fold(0.0, (a, b) => b > a ? b : a);

  // ---- persistence ----------------------------------------------------------

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    _goalName = p.getString(_kGoalName) ?? _goalName;
    _target = p.getDouble(_kTarget) ?? _target;
    _balance = p.getDouble(_kBalance) ?? _balance;
    final raw = p.getString(_kDeposits);
    if (raw != null) {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      _deposits
        ..clear()
        ..addAll(list.map(Deposit.fromJson));
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kGoalName, _goalName);
    await p.setDouble(_kTarget, _target);
    await p.setDouble(_kBalance, _balance);
    await p.setString(
        _kDeposits, jsonEncode(_deposits.map((d) => d.toJson()).toList()));
  }

  // ---- mutations ------------------------------------------------------------

  /// Adds [amount] to the balance. Returns the list of milestone fractions that
  /// this deposit *newly* crossed, so the UI can fire a golden burst.
  List<double> deposit(double amount, {DateTime? at}) {
    if (amount <= 0) return const [];
    final before = _milestoneFor;
    _balance += amount;
    _deposits.insert(0, Deposit(amount: amount, at: at ?? DateTime.now()));
    final after = _milestoneFor;
    _save();
    notifyListeners();
    return kMilestones.where((m) => m > before && m <= after).toList();
  }

  void setGoal({required String name, required double target}) {
    _goalName = name.trim().isEmpty ? _goalName : name.trim();
    _target = target <= 0 ? _target : target;
    _save();
    notifyListeners();
  }

  void reset() {
    _balance = 0;
    _deposits.clear();
    _save();
    notifyListeners();
  }
}

/// Shared singleton so every screen acts on the same savings data.
final savingsStore = SavingsStore();
