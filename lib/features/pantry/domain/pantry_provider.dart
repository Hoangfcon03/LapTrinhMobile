import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/pantry_data.dart';

class PantryProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Ingredient> _ingredients = [];
  List<Ingredient> get ingredients => _ingredients;

  List<Ingredient> get expiredIngredients => _ingredients.where((i) => i.isExpired).toList();
  List<Ingredient> get expiringSoonIngredients => _ingredients.where((i) => i.isExpiringSoon).toList();

  Future<void> fetchIngredients() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final snapshot = await _firestore.collection('users').doc(user.uid).collection('ingredients').get();
    _ingredients = snapshot.docs.map((doc) {
      final data = doc.data();
      return Ingredient(
        id: doc.id,
        name: data['name'] ?? '',
        quantity: data['quantity'] ?? '',
        expiryDate: (data['expiryDate'] as Timestamp).toDate(),
        category: data['category'] ?? 'Chung',
      );
    }).toList();
    notifyListeners();
  }

  Future<void> addIngredient(Ingredient item) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final docRef = await _firestore.collection('users').doc(user.uid).collection('ingredients').add({
      'name': item.name,
      'quantity': item.quantity,
      'expiryDate': Timestamp.fromDate(item.expiryDate),
      'category': item.category,
    });
    fetchIngredients();
  }

  Future<void> removeIngredient(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await _firestore.collection('users').doc(user.uid).collection('ingredients').doc(id).delete();
    _ingredients.removeWhere((i) => i.id == id);
    notifyListeners();
  }

  Future<void> updateQuantity(String id, String newQty) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if (newQty.trim().toLowerCase() == 'hết' || newQty == '0') {
      await removeIngredient(id);
    } else {
      await _firestore.collection('users').doc(user.uid).collection('ingredients').doc(id).update({'quantity': newQty});
      fetchIngredients();
    }
  }

  Future<void> seedFullAppData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final batch = _firestore.batch();
    final now = DateTime.now();

    // 1. SINH DỮ LIỆU KHO (PANTRY) - 15+ Nguyên liệu phong phú
    final pantryRef = _firestore.collection('users').doc(user.uid).collection('ingredients');

    final dummyIngredients = [
      // Nhóm THỊT & HẢI SẢN
      {'name': 'Thịt bò thăn', 'quantity': '500g', 'expiryDate': now.subtract(const Duration(days: 1)), 'category': 'Thịt'}, // Đã hết hạn
      {'name': 'Ức gà', 'quantity': '400g', 'expiryDate': now.add(const Duration(days: 5)), 'category': 'Thịt'},
      {'name': 'Tôm tươi', 'quantity': '300g', 'expiryDate': now.add(const Duration(days: 1)), 'category': 'Hải sản'}, // Sắp hết hạn
      {'name': 'Cá hồi', 'quantity': '200g', 'expiryDate': now.add(const Duration(days: 2)), 'category': 'Hải sản'}, // Sắp hết hạn

      // Nhóm RAU CỦ QUẢ
      {'name': 'Cà chua', 'quantity': '5 quả', 'expiryDate': now.add(const Duration(days: 4)), 'category': 'Rau củ'},
      {'name': 'Bông cải xanh', 'quantity': '1 cây', 'expiryDate': now.subtract(const Duration(days: 2)), 'category': 'Rau củ'}, // Đã hết hạn
      {'name': 'Cà rốt', 'quantity': '3 củ', 'expiryDate': now.add(const Duration(days: 10)), 'category': 'Rau củ'},
      {'name': 'Hành tây', 'quantity': '2 củ', 'expiryDate': now.add(const Duration(days: 15)), 'category': 'Rau củ'},
      {'name': 'Khoai tây', 'quantity': '1kg', 'expiryDate': now.add(const Duration(days: 20)), 'category': 'Rau củ'},

      // Nhóm TRỨNG & SỮA
      {'name': 'Trứng gà', 'quantity': '10 quả', 'expiryDate': now.add(const Duration(days: 7)), 'category': 'Trứng'},
      {'name': 'Sữa tươi không đường', 'quantity': '1 lít', 'expiryDate': now.add(const Duration(days: 1)), 'category': 'Sữa'}, // Sắp hết hạn
      {'name': 'Phô mai lát', 'quantity': '1 gói', 'expiryDate': now.add(const Duration(days: 30)), 'category': 'Sữa'},

      // Nhóm ĐỒ KHÔ & GIA VỊ
      {'name': 'Mì Ý (Spaghetti)', 'quantity': '500g', 'expiryDate': now.add(const Duration(days: 300)), 'category': 'Đồ khô'},
      {'name': 'Gạo ST25', 'quantity': '5kg', 'expiryDate': now.add(const Duration(days: 365)), 'category': 'Gạo'},
      {'name': 'Nấm hương khô', 'quantity': '100g', 'expiryDate': now.add(const Duration(days: 180)), 'category': 'Đồ khô'},
    ];

    for (var item in dummyIngredients) {
      batch.set(pantryRef.doc(), {
        'name': item['name'],
        'quantity': item['quantity'],
        'expiryDate': Timestamp.fromDate(item['expiryDate'] as DateTime),
        'category': item['category'],
      });
    }

    // 2. SINH CÔNG THỨC MẪU (Để khớp với nguyên liệu trên)
    final recipeRef = _firestore.collection('recipes');
    final dummyRecipes = [
      {
        'title': 'Mì Ý sốt bò băm',
        'ingredients': ['Mì Ý (Spaghetti)', 'Thịt bò thăn', 'Cà chua', 'Hành tây'],
        'cookTime': 30, 'cuisine': 'Âu', 'mealType': 'Tối',
        'imageUrl': 'https://images.unsplash.com/photo-1510627489930-0c1b0ba9448f?q=80&w=400',
        'steps': ['Luộc mì', 'Làm sốt bò băm', 'Trộn mì với sốt']
      },
      {
        'title': 'Cơm gà cà rốt',
        'ingredients': ['Gạo ST25', 'Ức gà', 'Cà rốt'],
        'cookTime': 45, 'cuisine': 'Á', 'mealType': 'Trưa',
        'imageUrl': 'https://images.unsplash.com/photo-1512058560366-cd2427ff596b?q=80&w=400',
        'steps': ['Nấu cơm', 'Xào gà với cà rốt', 'Trình bày']
      },
      {
        'title': 'Salad trứng hải sản',
        'ingredients': ['Trứng gà', 'Tôm tươi', 'Cà chua', 'Hành tây'],
        'cookTime': 15, 'cuisine': 'Âu', 'mealType': 'Sáng',
        'imageUrl': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?q=80&w=400',
        'steps': ['Luộc trứng và tôm', 'Thái rau củ', 'Trộn với sốt salad']
      }
    ];

    for (var r in dummyRecipes) {
      batch.set(recipeRef.doc(), r);
    }

    await batch.commit();
    await fetchIngredients();
    notifyListeners();
  }
}