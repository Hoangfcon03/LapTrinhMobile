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
        // LỌC DANH SÁCH: Theo từ khóa tìm kiếm
        final filteredIngredients = provider.ingredients.where((item) {
          return item.name.toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Kho Nguyên Liệu'),
            centerTitle: true,
          ),
          body: Column(
            children: [
              // --- THANH TÌM KIẾM (FR1.4) ---
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Tìm nhanh nguyên liệu...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() {
                        searchQuery = "";
                      }),
                    )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                ),
              ),

              // --- DANH SÁCH HIỂN THỊ ---
              Expanded(
                child: filteredIngredients.isEmpty
                    ? Center(
                    child: Text(searchQuery.isEmpty
                        ? 'Kho trống. Nhấn + để thêm đồ!'
                        : 'Không tìm thấy "$searchQuery"'))
                    : ListView.builder(
                  itemCount: filteredIngredients.length,
                  itemBuilder: (context, index) {
                    final item = filteredIngredients[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: Icon(
                          Icons.circle,
                          color: item.isExpired
                              ? Colors.red
                              : (item.isExpiringSoon ? Colors.orange : Colors.green),
                        ),
                        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Còn: ${item.quantity} - HSD: ${item.expiryDate.day}/${item.expiryDate.month}/${item.expiryDate.year}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showEditQtyDialog(context, provider, item),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => _confirmDelete(context, provider, item),
                            ),
                          ],
                        ),
                      ),
                    );
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

  // --- HÀM 1: CẬP NHẬT SỐ LƯỢNG ---
  void _showEditQtyDialog(BuildContext context, PantryProvider provider, Ingredient item) {
    final controller = TextEditingController(text: item.quantity);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Sửa số lượng: ${item.name}'),
        content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Nhập 'hết' hoặc '0' để xóa")
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('HỦY')),
          ElevatedButton(
              onPressed: () {
                provider.updateQuantity(item.id, controller.text);
                Navigator.pop(ctx);
              },
              child: const Text('CẬP NHẬT')
          ),
        ],
      ),
    );
  }

  // --- HÀM 2: THÊM MỚI NGUYÊN LIỆU ---
  void _showAddDialog(BuildContext context, PantryProvider provider) {
    final nameC = TextEditingController();
    final qtyC = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: const Text('Thêm vào kho'),
          content: SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameC, decoration: const InputDecoration(labelText: 'Tên thực phẩm')),
                  TextField(controller: qtyC, decoration: const InputDecoration(labelText: 'Số lượng (VD: 500g, 2 củ)')),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text("Hạn dùng: "),
                      TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.now().subtract(const Duration(days: 365)),
                              lastDate: DateTime(2030)
                          );
                          if (picked != null) setStateDialog(() => selectedDate = picked);
                        },
                        child: Text("${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"),
                      ),
                    ],
                  )
                ]
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
                        expiryDate: selectedDate,
                        category: 'Chung'
                    ));
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('THÊM')
            )
          ],
        ),
      ),
    );
  }

  // --- HÀM 3: XÁC NHẬN XÓA ---
  void _confirmDelete(BuildContext context, PantryProvider provider, Ingredient item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa "${item.name}" khỏi kho không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('HỦY')),
          TextButton(
              onPressed: () {
                provider.removeIngredient(item.id);
                Navigator.pop(ctx);
              },
              child: const Text('XÓA', style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }
}