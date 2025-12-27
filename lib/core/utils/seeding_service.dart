import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SeedingService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> seedAppData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final batch = _db.batch();

    // --- 1. SEED NGUYÊN LIỆU (PANTRY) ---
    final pantryRef = _db.collection('users').doc(user.uid).collection('ingredients');

    final ingredients = [
      {'name': 'Thịt bò', 'quantity': '300g', 'category': 'Thịt', 'expiryDate': Timestamp.fromDate(DateTime.now().add(Duration(days: 5)))},
      {'name': 'Trứng gà', 'quantity': '5 quả', 'category': 'Trứng', 'expiryDate': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 1)))}, // Hết hạn
      {'name': 'Cà chua', 'quantity': '2 quả', 'category': 'Rau củ', 'expiryDate': Timestamp.fromDate(DateTime.now().add(Duration(days: 2)))},
      {'name': 'Hành tây', 'quantity': '1 củ', 'category': 'Rau củ', 'expiryDate': Timestamp.fromDate(DateTime.now().add(Duration(days: 7)))},
    ];

    for (var ing in ingredients) {
      batch.set(pantryRef.doc(), ing);
    }

    // --- 2. SEED CÔNG THỨC (RECIPES) ---
    // Lưu ý: Công thức thường dùng chung cho mọi user nên để ở collection gốc
    final recipeRef = _db.collection('recipes');

    final recipes = [
      {
        'name': 'Bò xào hành tây',
        'description': 'Món ăn đậm đà, dễ làm.',
        'ingredients': ['Thịt bò', 'Hành tây'],
        'image': 'https://example.com/bo-xao.jpg'
      },
      {
        'name': 'Trứng xào cà chua',
        'description': 'Món ăn quốc dân sinh viên.',
        'ingredients': ['Trứng gà', 'Cà chua'],
        'image': 'https://example.com/trung-ca-chua.jpg'
      }
    ];

    for (var recipe in recipes) {
      batch.set(recipeRef.doc(), recipe);
    }

    await batch.commit();
  }
}