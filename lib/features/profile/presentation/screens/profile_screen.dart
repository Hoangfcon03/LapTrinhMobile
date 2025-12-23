import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bepthongminh64pm1duchoang/features/auth/domain/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy thông tin user từ AuthProvider
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ cá nhân'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 30),
          // Ảnh đại diện giả lập
          const Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.green,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            user?.name ?? 'Khách',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            user?.email ?? 'Chưa cập nhật email',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),
          const Divider(),

          // Danh sách các tùy chọn
          _buildOptionItem(Icons.history, 'Lịch sử nấu ăn', () {}),
          _buildOptionItem(Icons.settings, 'Cài đặt thông báo', () {}),
          _buildOptionItem(Icons.help_outline, 'Hướng dẫn sử dụng', () {}),

          const Spacer(),

          // NÚT ĐĂNG XUẤT
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  auth.logout();
                  // Sau khi logout, main.dart sẽ tự động đưa người dùng về AuthScreen
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text('ĐĂNG XUẤT', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}