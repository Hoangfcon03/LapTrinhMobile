enum AlertSeverity { info, warning, critical }

class AlertModel {
  final String ingredientName;
  final DateTime expiryDate;
  final AlertSeverity severity;

  AlertModel({
    required this.ingredientName,
    required this.expiryDate,
    required this.severity,
  });
}