import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bepthongminh64pm1duchoang/features/pantry/domain/pantry_provider.dart';
import 'package:bepthongminh64pm1duchoang/features/pantry/data/pantry_data.dart';

class PantryScreen extends StatefulWidget {
  const PantryScreen({super.key});

  @override
  State<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends State<PantryScreen> {
  String searchQuery = ""; // Lưu từ khóa tìm kiếm

  @override
  Widget build(BuildContext context) {
    return Consumer<PantryProvider>(
      builder: (context, provider, child) {
        // 1. LỌC DANH SÁCH THEO TÊN
        final filteredIngredients = provider.ingredients.where((item) {
          return item.name.toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Kho Nguyên Liệu'),
            centerTitle: true,
            elevation: 0,
          ),
          body: Column(
            children: [
              // 2. THANH TÌM KIẾM
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  onChanged: (value) => setState(() => searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Tìm nhanh nguyên liệu...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => searchQuery = ""))
                        : null,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                ),
              ),

              // 3. DANH SÁCH NGUYÊN LIỆU
              Expanded(
                child: filteredIngredients.isEmpty
                    ? Center(child: Text(searchQuery.isEmpty ? 'Kho trống. Nhấn + để thêm đồ!' : 'Không tìm thấy "$searchQuery"'))
                    : ListView.builder(
                  itemCount: filteredIngredients.length,
                  padding: const EdgeInsets.only(bottom: 80),
                  itemBuilder: (context, index) {
                    final item = filteredIngredients[index];
                    return _buildIngredientCard(context, provider, item);
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddDialog(context, provider),
            backgroundColor: Colors.green,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  // WIDGET HIỂN THỊ TỪNG DÒNG NGUYÊN LIỆU
  Widget _buildIngredientCard(BuildContext context, PantryProvider provider, Ingredient item) {
    // Xác định màu sắc theo trạng thái hạn dùng
    Color statusColor = item.isExpired ? Colors.red : (item.isExpiringSoon ? Colors.orange : Colors.green);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        // HIỂN THỊ HÌNH ẢNH
        leading: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: item.imageUrl.isNotEmpty
                  ? Image.network(
                item.imageUrl,
                width: 55,
                height: 55,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
              )
                  : _buildPlaceholder(),
            ),
            // Chấm màu báo trạng thái hạn dùng đè lên ảnh
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            )
          ],
        ),
        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Số lượng: ${item.quantity}'),
            Text(
              'HSD: ${item.expiryDate.day}/${item.expiryDate.month}/${item.expiryDate.year}',
              style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit, color: Colors.blue, size: 20), onPressed: () => _showEditQtyDialog(context, provider, item)),
            IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20), onPressed: () => _confirmDelete(context, provider, item)),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 55, height: 55,
      color: Colors.grey.shade200,
      child: const Icon(Icons.restaurant, color: Colors.grey),
    );
  }

  // --- CÁC DIALOG CHỨC NĂNG ---

  void _showEditQtyDialog(BuildContext context, PantryProvider provider, Ingredient item) {
    final controller = TextEditingController(text: item.quantity);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Sửa số lượng: ${item.name}'),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: "Nhập 'hết' để xóa")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('HỦY')),
          ElevatedButton(
            onPressed: () {
              provider.updateQuantity(item.id, controller.text);
              Navigator.pop(ctx);
            },
            child: const Text('CẬP NHẬT'),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context, PantryProvider provider) {
    final nameC = TextEditingController();
    final qtyC = TextEditingController();
    final imgC = TextEditingController(); // Ô nhập link ảnh
    DateTime date = DateTime.now().add(const Duration(days: 7));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: const Text('Thêm nguyên liệu mới'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameC, decoration: const InputDecoration(labelText: 'Tên thực phẩm')),
                TextField(controller: qtyC, decoration: const InputDecoration(labelText: 'Số lượng (g, kg, quả...)')),
                TextField(controller: imgC, decoration: const InputDecoration(labelText: 'Link hình ảnh (URL)')),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text("HSD: "),
                    TextButton(
                      onPressed: () async {
                        final p = await showDatePicker(context: context, initialDate: date, firstDate: DateTime.now().subtract(const Duration(days: 30)), lastDate: DateTime(2030));
                        if (p != null) setStateDialog(() => date = p);
                      },
                      child: Text("${date.day}/${date.month}/${date.year}"),
                    )
                  ],
                )
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('HỦY')),
            ElevatedButton(
              onPressed: () {
                if (nameC.text.isNotEmpty) {
                  provider.addIngredient(Ingredient(
                      id: '',
                      name: nameC.text,
                      quantity: qtyC.text,
                      expiryDate: date,
                      category: 'Chung',
                      imageUrl: imgC.text // Lưu link ảnh
                  ));
                  Navigator.pop(ctx);
                }
              },
              child: const Text('THÊM'),
            )
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, PantryProvider provider, Ingredient item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận'),
        content: Text('Bạn có chắc muốn xóa "${item.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('HỦY')),
          TextButton(onPressed: () { provider.removeIngredient(item.id); Navigator.pop(ctx); }, child: const Text('XÓA', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}