import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/pantry_provider.dart';
import '../../data/pantry_data.dart';

class PantryScreen extends StatelessWidget {
  const PantryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PantryProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Kho Nguyên Liệu')),
          body: provider.ingredients.isEmpty
              ? const Center(child: Text('Kho của bạn đang trống!'))
              : ListView.builder(
            itemCount: provider.ingredients.length,
            itemBuilder: (context, index) {
              final item = provider.ingredients[index];
              return ListTile(
                leading: Icon(Icons.circle, color: item.isExpired ? Colors.red : Colors.green),
                title: Text(item.name),
                subtitle: Text('HSD: ${item.expiryDate.day}/${item.expiryDate.month} - SL: ${item.quantity}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => provider.removeIngredient(item.id),
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddDialog(context, provider),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  void _showAddDialog(BuildContext context, PantryProvider provider) {
    final nameC = TextEditingController();
    final qtyC = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thêm nguyên liệu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameC, decoration: const InputDecoration(labelText: 'Tên')),
            TextField(controller: qtyC, decoration: const InputDecoration(labelText: 'Số lượng')),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              provider.addIngredient(Ingredient(
                id: '', // Firestore tự tạo ID
                name: nameC.text,
                quantity: qtyC.text,
                expiryDate: DateTime.now().add(const Duration(days: 5)),
                category: 'Gia vị',
              ));
              Navigator.pop(ctx);
            },
            child: const Text('Lưu'),
          )
        ],
      ),
    );
  }
}