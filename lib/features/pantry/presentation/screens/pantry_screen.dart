import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bepthongminh64pm1duchoang/features/pantry/domain/pantry_provider.dart';
import 'package:bepthongminh64pm1duchoang/features/pantry/data/pantry_data.dart';

class PantryScreen extends StatelessWidget {
  const PantryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PantryProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Kho Nguyên Liệu')),
          body: provider.ingredients.isEmpty
              ? const Center(child: Text('Kho trống. Nhấn + để thêm đồ!'))
              : ListView.builder(
            itemCount: provider.ingredients.length,
            itemBuilder: (context, index) {
              final item = provider.ingredients[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: Icon(Icons.circle, color: item.isExpired ? Colors.red : Colors.green),
                  title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Còn: ${item.quantity} - HSD: ${item.expiryDate.day}/${item.expiryDate.month}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showEditQtyDialog(context, provider, item),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.grey),
                        onPressed: () => provider.removeIngredient(item.id),
                      ),
                    ],
                  ),
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

  void _showEditQtyDialog(BuildContext context, PantryProvider provider, Ingredient item) {
    final controller = TextEditingController(text: item.quantity);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Sửa số lượng: ${item.name}'),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: "Nhập 'hết' để xóa")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('HỦY')),
          ElevatedButton(onPressed: () {
            provider.updateQuantity(item.id, controller.text);
            Navigator.pop(ctx);
          }, child: const Text('CẬP NHẬT')),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context, PantryProvider provider) {
    final nameC = TextEditingController();
    final qtyC = TextEditingController();
    DateTime date = DateTime.now().add(const Duration(days: 7));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Thêm vào kho'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: nameC, decoration: const InputDecoration(labelText: 'Tên thực phẩm')),
            TextField(controller: qtyC, decoration: const InputDecoration(labelText: 'Số lượng')),
            TextButton(
              onPressed: () async {
                final p = await showDatePicker(context: context, initialDate: date, firstDate: DateTime.now(), lastDate: DateTime(2030));
                if (p != null) setState(() => date = p);
              },
              child: Text("Hạn dùng: ${date.day}/${date.month}/${date.year}"),
            )
          ]),
          actions: [
            ElevatedButton(onPressed: () {
              provider.addIngredient(Ingredient(id: '', name: nameC.text, quantity: qtyC.text, expiryDate: date, category: 'Chung'));
              Navigator.pop(ctx);
            }, child: const Text('THÊM'))
          ],
        ),
      ),
    );
  }
}