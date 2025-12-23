//Tủ nguyên liệu ảo
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bepthongminh64pm1duchoang/features/pantry/domain/pantry_provider.dart';
import 'package:bepthongminh64pm1duchoang/features/pantry/data/pantry_data.dart';

class PantryScreen extends StatelessWidget {
  const PantryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PantryProvider>(
      builder: (context, pantryProvider, child) {
        final ingredients = pantryProvider.ingredients;
        final expiringItems = pantryProvider.expiringIngredients;
        final groupedItems = _groupIngredientsByCategory(ingredients);

        return Scaffold(
          appBar: AppBar(title: const Text('Kho Nguyên liệu Ảo')),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddIngredientDialog(context, pantryProvider),
            label: const Text('Thêm Nguyên liệu'),
            icon: const Icon(Icons.add),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hiển thị Cảnh báo nếu có đồ sắp hết hạn
                if (expiringItems.isNotEmpty)
                  _buildExpiryAlert(context, expiringItems),

                const SizedBox(height: 20),
                Text(
                  'Nguyên liệu Hiện có (${ingredients.length})',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                if (ingredients.isEmpty)
                  _buildEmptyState()
                else
                  ..._buildIngredientList(context, groupedItems, pantryProvider),

                const SizedBox(height: 80), // Tạo khoảng trống cho FAB
              ],
            ),
          ),
        );
      },
    );
  }

  // --- WIDGET CẢNH BÁO ---
  Widget _buildExpiryAlert(BuildContext context, List<Ingredient> items) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.orange),
              const SizedBox(width: 8),
              Text('Sắp hết hạn (${items.length})',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
            ],
          ),
          ...items.map((item) => ListTile(
            dense: true,
            title: Text(item.name),
            subtitle: Text('Còn lại ${item.expiryDate.difference(DateTime.now()).inDays} ngày'),
          )).toList(),
        ],
      ),
    );
  }

  // --- DIALOG THÊM NGUYÊN LIỆU (ĐÃ SỬA LỖI ID) ---
  void _showAddIngredientDialog(BuildContext context, PantryProvider provider) {
    final nameController = TextEditingController();
    final qtyController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thêm mới'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Tên')),
            TextField(controller: qtyController, decoration: const InputDecoration(labelText: 'Số lượng')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                provider.addIngredient(Ingredient(
                  // SỬA LỖI: Tạo ID bằng timestamp
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  quantity: qtyController.text,
                  expiryDate: DateTime.now().add(const Duration(days: 5)),
                  category: 'Thực phẩm mới',
                ));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  // Các hàm bổ trợ khác
  Map<String, List<Ingredient>> _groupIngredientsByCategory(List<Ingredient> items) {
    Map<String, List<Ingredient>> map = {};
    for (var item in items) {
      map.putIfAbsent(item.category, () => []).add(item);
    }
    return map;
  }

  List<Widget> _buildIngredientList(BuildContext context, Map<String, List<Ingredient>> groups, PantryProvider provider) {
    return groups.entries.map((entry) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(entry.key, style: const TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold)),
        ),
        ...entry.value.map((item) => Card(
          child: ListTile(
            title: Text(item.name),
            subtitle: Text('HSD: ${item.expiryDate.day}/${item.expiryDate.month}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => provider.removeIngredient(item),
            ),
          ),
        )).toList(),
      ],
    )).toList();
  }

  Widget _buildEmptyState() => const Center(child: Text('Kho trống rỗng!'));
}