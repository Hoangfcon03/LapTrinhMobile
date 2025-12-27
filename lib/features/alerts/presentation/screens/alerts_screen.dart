import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bepthongminh64pm1duchoang/features/pantry/domain/pantry_provider.dart';
import 'package:bepthongminh64pm1duchoang/features/pantry/data/pantry_data.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách Cảnh báo'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Consumer<PantryProvider>(
        builder: (context, pantry, child) {
          final expired = pantry.expiredIngredients;
          final soon = pantry.expiringSoonIngredients;

          if (expired.isEmpty && soon.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
                  SizedBox(height: 16),
                  Text('Tất cả thực phẩm đều an toàn!', style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // MỤC 1: ĐÃ HẾT HẠN
              if (expired.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text("❌ ĐÃ HẾT HẠN (CẦN LOẠI BỎ)",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 14)),
                ),
                ...expired.map((item) => _buildAlertCard(context, item, Colors.red, true)),
                const SizedBox(height: 20),
              ],

              // MỤC 2: SẮP HẾT HẠN
              if (soon.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text("⚠️ SẮP HẾT HẠN (ƯU TIÊN SỬ DỤNG)",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 14)),
                ),
                ...soon.map((item) => _buildAlertCard(context, item, Colors.orange, false)),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, Ingredient item, Color color, bool isExpired) {
    return Card(
      elevation: 0,
      color: color.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.3)),
      ),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: const Icon(Icons.priority_high, color: Colors.white, size: 20),
        ),
        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('HSD: ${item.expiryDate.day}/${item.expiryDate.month}/${item.expiryDate.year}'),
        trailing: isExpired
            ? IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () {
            Provider.of<PantryProvider>(context, listen: false).removeIngredient(item.id);
          },
        )
            : const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }
}