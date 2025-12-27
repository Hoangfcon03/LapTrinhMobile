import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bepthongminh64pm1duchoang/features/auth/domain/auth_provider.dart';
import 'package:bepthongminh64pm1duchoang/features/pantry/domain/pantry_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final pantry = Provider.of<PantryProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt hệ thống')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // NÚT QUAN TRỌNG NHẤT: SINH DỮ LIỆU
          Card(
            color: Colors.blue.shade50,
            child: ListTile(
              leading: const Icon(Icons.storage, color: Colors.blue),
              title: const Text('Khởi tạo dữ liệu App', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Nhấn để tạo sẵn Kho thực phẩm và Công thức mẫu'),
              onTap: () async {
                await pantry.seedFullAppData();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Dữ liệu đã được nạp hoàn tất!'))
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => auth.logout(),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ĐĂNG XUẤT', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}