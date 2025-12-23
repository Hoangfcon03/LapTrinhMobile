import 'package:flutter/material.dart';

// --- CLASS MODEL Ingredient (FR1 & FR3) ---
class Ingredient {
  final String id; // Thêm ID để dễ dàng quản lý (xóa/sửa)
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

  // --- Logic Cảnh báo Hết hạn (FR3) ---

  // Kiểm tra nếu đã hết hạn hoàn toàn
  bool get isExpired => expiryDate.isBefore(DateTime.now());

  // Kiểm tra nếu sắp hết hạn (trong vòng 3 ngày)
  bool get isExpiringSoon {
    final difference = expiryDate.difference(DateTime.now()).inDays;
    return difference >= 0 && difference <= 3;
  }
}

// --- MOCK DATA (Dữ liệu mẫu cho FR1/FR2/FR3) ---
final List<Ingredient> mockIngredients = [
  Ingredient(
      id: '1',
      name: 'Thịt bò',
      quantity: '200g',
      expiryDate: DateTime.now().add(const Duration(days: 4)),
      category: 'Thịt'
  ),
  Ingredient(
      id: '2',
      name: 'Sữa tươi',
      quantity: '500ml',
      expiryDate: DateTime.now().add(const Duration(days: 2)), // Cảnh báo Warning
      category: 'Sữa'
  ),
  Ingredient(
      id: '3',
      name: 'Cà rốt',
      quantity: '1 củ',
      expiryDate: DateTime.now().add(const Duration(days: 7)),
      category: 'Rau củ'
  ),
  Ingredient(
      id: '4',
      name: 'Hành tây',
      quantity: '1 củ',
      expiryDate: DateTime.now().subtract(const Duration(days: 1)), // Đã hết hạn (Critical)
      category: 'Rau củ'
  ),
  Ingredient(
      id: '5',
      name: 'Trứng gà',
      quantity: '4 quả',
      expiryDate: DateTime.now().add(const Duration(days: 1)), // Rất sắp hết hạn
      category: 'Trứng'
  ),
];