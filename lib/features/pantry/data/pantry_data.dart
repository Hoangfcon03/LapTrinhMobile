import 'package:cloud_firestore/cloud_firestore.dart';

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

  // FR3: Logic kiểm tra trạng thái hạn sử dụng
  bool get isExpired => expiryDate.isBefore(DateTime.now());

  bool get isExpiringSoon {
    final now = DateTime.now();
    final threeDaysFromNow = now.add(const Duration(days: 3));
    return expiryDate.isAfter(now) && expiryDate.isBefore(threeDaysFromNow);
  }
}

class Recipe {
  final String id;
  final String title;
  final List<String> ingredients;
  final List<String> steps;
  final String imageUrl;

  Recipe({
    required this.id,
    required this.title,
    required this.ingredients,
    required this.steps,
    required this.imageUrl,
  });
}