enum AlertSeverity { warning, critical }

class ExpiryAlert {
  final String ingredientId;
  final String ingredientName;
  final DateTime expiryDate;
  final AlertSeverity severity;

  ExpiryAlert({
    required this.ingredientId,
    required this.ingredientName,
    required this.expiryDate,
    required this.severity,
  });
}