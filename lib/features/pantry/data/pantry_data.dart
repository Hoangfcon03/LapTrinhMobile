class Ingredient {
  final String id;
  final String name;
  final String quantity;
  final DateTime expiryDate;
  final String category;

  Ingredient({
    required this.id,
    required this.name,
    required this.quantity,
    required this.expiryDate,
    required this.category,
  });

  // Logic FR3: Kiểm tra sắp hết hạn (trong 3 ngày)
  bool get isExpiringSoon {
    final diff = expiryDate.difference(DateTime.now()).inDays;
    return diff >= 0 && diff <= 3;
  }

  // Kiểm tra đã hết hạn hoàn toàn
  bool get isExpired => expiryDate.isBefore(DateTime.now());
}