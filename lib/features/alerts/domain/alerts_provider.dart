import 'package:flutter/material.dart';

// SỬA LỖI IMPORT TUYỆT ĐỐI
import 'package:bepthongminh64pm1duchoang/features/alerts/domain/alert_model.dart';
import 'package:bepthongminh64pm1duchoang/features/pantry/data/pantry_data.dart';

class AlertsProvider with ChangeNotifier {
  List<AlertModel> _alerts = [];
  List<AlertModel> get alerts => _alerts;

  void checkExpirations(List<Ingredient> ingredients) {
    _alerts.clear();
    for (var item in ingredients) {
      // isExpired và isExpiringSoon được định nghĩa trong class Ingredient
      if (item.isExpired) {
        _alerts.add(AlertModel(
          ingredientName: item.name,
          expiryDate: item.expiryDate,
          severity: AlertSeverity.critical,
        ));
      } else if (item.isExpiringSoon) {
        _alerts.add(AlertModel(
          ingredientName: item.name,
          expiryDate: item.expiryDate,
          severity: AlertSeverity.warning,
        ));
      }
    }
    notifyListeners();
  }
}