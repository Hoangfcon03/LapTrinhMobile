import 'package:flutter/material.dart';
import 'package:bepthongminh64pm1duchoang/features/pantry/data/pantry_data.dart';
import 'package:bepthongminh64pm1duchoang/features/alerts/domain/alert_model.dart';

class AlertsProvider with ChangeNotifier {
  List<ExpiryAlert> _alerts = [];
  List<ExpiryAlert> get alerts => _alerts;

  // Logic kiểm tra ngày hết hạn
  void checkExpirations(List<Ingredient> ingredients) {
    final now = DateTime.now();
    _alerts = [];

    for (var item in ingredients) {
      if (item.expiryDate == null) continue;

      final daysUntilExpiry = item.expiryDate!.difference(now).inDays;

      if (daysUntilExpiry <= 0) {
        _alerts.add(ExpiryAlert(
          ingredientId: item.id,
          ingredientName: item.name,
          expiryDate: item.expiryDate!,
          severity: AlertSeverity.critical,
        ));
      } else if (daysUntilExpiry <= 3) {
        _alerts.add(ExpiryAlert(
          ingredientId: item.id,
          ingredientName: item.name,
          expiryDate: item.expiryDate!,
          severity: AlertSeverity.warning,
        ));
      }
    }
    notifyListeners();
  }
}