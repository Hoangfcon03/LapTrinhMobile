import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import Providers và Models
import '../../domain/pantry_provider.dart';
import '../../data/pantry_data.dart'; // Chứa class Ingredient

class PantryScreen extends StatelessWidget {
  const PantryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sử dụng Consumer để lắng nghe PantryProvider
    return Consumer<PantryProvider>(
      builder: (context, pantryProvider, child) {
        final List<Ingredient> ingredients = pantryProvider.ingredients;
        final List<Ingredient> expiringItems = pantryProvider.expiringIngredients;

        // Nhóm nguyên liệu theo thể loại
        final groupedItems = _groupIngredientsByCategory(ingredients);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Kho Nguyên liệu Ảo'),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () { /* Xử lý tìm kiếm */ },
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              // Thêm logic: Mở dialog/màn hình để nhập dữ liệu
              _showAddIngredientDialog(context, pantryProvider);
            },
            label: const Text('Thêm Nguyên liệu'),
            icon: const Icon(Icons.add),
            backgroundColor: Theme.of(context).primaryColor,
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Cảnh báo Hết hạn (FR3) ---
                if (expiringItems.isNotEmpty)
                  _buildExpiryAlert(context, expiringItems),

                const SizedBox(height: 20),

                // --- Danh sách Nguyên liệu (FR1) ---
                Text(
                  'Nguyên liệu Hiện có (${ingredients.length})',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                // Hiển thị danh sách nguyên liệu đã nhóm
                if (ingredients.isEmpty)
                  _buildEmptyPantryState()
                else
                  ..._buildIngredientList(context, groupedItems, pantryProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  // Method nhóm nguyên liệu
  Map<String, List<Ingredient>> _groupIngredientsByCategory(List<Ingredient> items) {
    return items.fold<Map<String, List<Ingredient>>>({}, (map, ingredient) {
      if (!map.containsKey(ingredient.category)) {
        map[ingredient.category] = [];
      }
      map[ingredient.category]!.add(ingredient);
      return map;
    });
  }

  // Widget hiển thị khi kho rỗng
  Widget _buildEmptyPantryState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(top: 80.0),
        child: Column(
          children: [
            Icon(Icons.kitchen_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 10),
            Text('Tủ lạnh ảo của bạn trống trơn!', style: TextStyle(fontSize: 18, color: Colors.grey)),
            Text('Hãy thêm nguyên liệu đầu tiên.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildExpiryAlert(BuildContext context, List<Ingredient> items) {
    // ... (Giữ nguyên logic hiển thị cảnh báo từ code trước)
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).hintColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).hintColor.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Theme.of(context).hintColor),
              const SizedBox(width: 8),
              Text(
                'Thực phẩm Sắp hết hạn (${items.length})',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).hintColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('• ${item.name} (${item.quantity})'),
                Text(
                  'Hết hạn sau ${item.expiryDate.difference(DateTime.now()).inDays} ngày',
                  style: TextStyle(
                      color: item.expiryDate.difference(DateTime.now()).inDays <= 1 ? Colors.red : Theme.of(context).hintColor,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
          )).toList(),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              icon: const Icon(Icons.restaurant),
              label: const Text('Gợi ý Công thức Ngay!'),
              onPressed: () {
                // Điều hướng đến tab Công thức (cần logic MainLayoutScreen)
              },
            ),
          )
        ],
      ),
    );
  }

  List<Widget> _buildIngredientList(BuildContext context, Map<String, List<Ingredient>> groupedItems, PantryProvider provider) {
    return groupedItems.entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.key,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50)),
            ),
            const Divider(),
            ...entry.value.map((item) => _buildIngredientTile(context, item, provider)).toList(),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildIngredientTile(BuildContext context, Ingredient item, PantryProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: const Icon(Icons.check_box_outline_blank, color: Colors.grey),
        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text('HSD: ${item.expiryDate.day}/${item.expiryDate.month} | ${item.quantity}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: () {
            // Logic xóa/dùng hết (FR1.3)
            provider.removeIngredient(item);
          },
        ),
        onTap: () {
          // Mở chi tiết/chỉnh sửa
        },
      ),
    );
  }

  // Dialog thêm nguyên liệu (FR1.1)
  void _showAddIngredientDialog(BuildContext context, PantryProvider provider) {
    // Đây là placeholder đơn giản cho việc thêm thủ công
    showDialog(
        context: context,
        builder: (ctx) {
          String name = '';
          String quantity = '';
          DateTime expiryDate = DateTime.now().add(const Duration(days: 7));

          return AlertDialog(
            title: const Text('Thêm Nguyên liệu Mới'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) => name = value,
                    decoration: const InputDecoration(labelText: 'Tên (Ví dụ: Thịt bò)'),
                  ),
                  TextField(
                    onChanged: (value) => quantity = value,
                    decoration: const InputDecoration(labelText: 'Số lượng (Ví dụ: 200g)'),
                  ),
                  // Lựa chọn HSD cần phức tạp hơn (dùng DatePicker)
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (name.isNotEmpty && quantity.isNotEmpty) {
                    // Giả định category là "Khác" nếu không có trường nhập
                    final newIng = Ingredient(
                      name: name,
                      quantity: quantity,
                      expiryDate: expiryDate,
                      category: 'Thực phẩm mới',
                    );
                    provider.addIngredient(newIng); // Gọi Provider để thêm
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Thêm'),
              ),
            ],
          );
        }
    );
  }
}