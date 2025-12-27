import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bepthongminh64pm1duchoang/features/pantry/domain/pantry_provider.dart';
import 'package:bepthongminh64pm1duchoang/features/pantry/data/pantry_data.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cảnh báo thực phẩm')),
      body: Consumer<PantryProvider>(
        builder: (context, pantry, _) {
          final expired = pantry.expiredIngredients;
          final soon = pantry.expiringSoonIngredients;

          if (expired.isEmpty && soon.isEmpty) {
            return const Center(child: Text('Mọi thứ đều ổn!'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (expired.isNotEmpty) ...[
                const Text("❌ HẾT HẠN", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ...expired.map((i) => _buildCard(context, i, Colors.red)),
              ],
              if (soon.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text("⚠️ SẮP HẾT HẠN", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                ...soon.map((i) => _buildCard(context, i, Colors.orange)),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildCard(BuildContext context, Ingredient item, Color color) {
    return Card(
      color: color.withAlpha(20),
      child: ListTile(
        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('HSD: ${item.expiryDate.day}/${item.expiryDate.month}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => Provider.of<PantryProvider>(context, listen: false).removeIngredient(item.id),
        ),
      ),
    );
  }
}