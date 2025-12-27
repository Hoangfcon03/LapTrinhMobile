import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// SỬA LỖI IMPORT TẠI ĐÂY
import 'package:bepthongminh64pm1duchoang/features/pantry/domain/pantry_provider.dart';
import 'package:bepthongminh64pm1duchoang/features/pantry/data/pantry_data.dart';

class AddIngredientScreen extends StatefulWidget {
  const AddIngredientScreen({super.key});

  @override
  State<AddIngredientScreen> createState() => _AddIngredientScreenState();
}

class _AddIngredientScreenState extends State<AddIngredientScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _quantity = '';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm thực phẩm mới')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Tên nguyên liệu (VD: Thịt bò)'),
                validator: (val) => (val == null || val.isEmpty) ? 'Vui lòng nhập tên' : null,
                onSaved: (val) => _name = val ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Số lượng (VD: 200g, 1 vỉ)'),
                validator: (val) => (val == null || val.isEmpty) ? 'Vui lòng nhập số lượng' : null,
                onSaved: (val) => _quantity = val ?? '',
              ),
              const SizedBox(height: 20),
              ListTile(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.grey, width: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                title: Text("Hạn sử dụng: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}"),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    // Tạo đối tượng Ingredient mới
                    final newIngredient = Ingredient(
                      id: '', // Firestore sẽ tự tạo ID
                      name: _name,
                      quantity: _quantity,
                      expiryDate: _selectedDate,
                      category: 'Thực phẩm',
                    );

                    // Gọi hàm add từ Provider
                    Provider.of<PantryProvider>(context, listen: false)
                        .addIngredient(newIngredient);

                    Navigator.pop(context);
                  }
                },
                child: const Text('LƯU VÀO KHO', style: TextStyle(fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
    );
  }
}