// lib/features/pantry/data/pantry_data.dart

import 'package:flutter/material.dart';

// --- CLASS MODEL Ingredient (FR1) ---
// Tạm thời đặt ở đây, sau này có thể tách ra domain/pantry_model.dart
class Ingredient {
  // name không thể null để tránh lỗi Null Safety
  final String name;
  final String quantity;
  final DateTime expiryDate;
  final String category;

  Ingredient({
    required this.name,
    required this.quantity,
    required this.expiryDate,
    required this.category,
  });

  // --- Logic Cảnh báo Hết hạn (FR3) ---
  // Thuộc tính tính toán để PantryProvider sử dụng
  bool get isExpiringSoon => expiryDate.difference(DateTime.now()).inDays <= 3;
}

// --- MOCK DATA (Dữ liệu giả cho FR1/FR3) ---
final List<Ingredient> mockIngredients = [
  Ingredient(
      name: 'Thịt bò',
      quantity: '200g',
      expiryDate: DateTime.now().add(const Duration(days: 4)),
      category: 'Thịt'
  ),
  Ingredient(
      name: 'Sữa tươi',
      quantity: '500ml',
      expiryDate: DateTime.now().add(const Duration(days: 2)), // Sắp hết hạn
      category: 'Sữa'
  ),
  Ingredient(
      name: 'Cà rốt',
      quantity: '1 củ',
      expiryDate: DateTime.now().add(const Duration(days: 7)),
      category: 'Rau củ'
  ),
  Ingredient(
      name: 'Hành tây',
      quantity: '1 củ',
      expiryDate: DateTime.now().add(const Duration(days: 1)), // Rất sắp hết hạn
      category: 'Rau củ'
  ),
];