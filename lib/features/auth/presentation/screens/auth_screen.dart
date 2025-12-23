import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- IMPORT TUYỆT ĐỐI ---
import 'package:bepthongminh64pm1duchoang/features/auth/domain/auth_provider.dart';
import 'package:bepthongminh64pm1duchoang/features/pantry/domain/pantry_provider.dart';
import 'package:bepthongminh64pm1duchoang/features/alerts/domain/alerts_provider.dart';
import 'package:bepthongminh64pm1duchoang/features/alerts/domain/alert_model.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  // --- HÀM HIỂN THỊ POPUP CẢNH BÁO ---
  void _showExpiryDialogIfNeeded(BuildContext context) {
    final alertsProvider = Provider.of<AlertsProvider>(context, listen: false);
    final pantryProvider = Provider.of<PantryProvider>(context, listen: false);

    // Quét kho thực phẩm
    alertsProvider.checkExpirations(pantryProvider.ingredients);

    // Kiểm tra nếu có đồ hết hạn (Critical)
    if (alertsProvider.alerts.any((a) => a.severity == AlertSeverity.critical)) {
      showDialog(
        context: context,
        barrierDismissible: false, // Bắt buộc người dùng phải tương tác
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 10),
              Text('Cảnh báo hết hạn!'),
            ],
          ),
          content: Text(
              'Phát hiện thực phẩm trong kho của bạn đã hết hạn. Hãy kiểm tra ngay để đảm bảo sức khỏe!'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ĐỂ SAU'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Sau này bạn có thể thêm logic chuyển tab tại đây
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('KIỂM TRA NGAY', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Theme.of(context).primaryColor, Colors.white],
          ),
        ),
        child: SafeArea(
          child: auth.isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : Column(
            children: [
              const SizedBox(height: 30),
              const Icon(Icons.restaurant_menu, size: 70, color: Colors.white),
              const Text('BẾP THÔNG MINH',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 30),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Column(
                    children: [
                      TabBar(
                        controller: _tabController,
                        labelColor: Theme.of(context).primaryColor,
                        tabs: const [Tab(text: 'ĐĂNG NHẬP'), Tab(text: 'ĐĂNG KÝ')],
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [_buildLogin(), _buildRegister()],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogin() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email))),
          const SizedBox(height: 15),
          TextField(controller: _passController, obscureText: true, decoration: const InputDecoration(labelText: 'Mật khẩu', prefixIcon: Icon(Icons.lock))),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                final success = await Provider.of<AuthProvider>(context, listen: false)
                    .login(_emailController.text, _passController.text);

                if (success && mounted) {
                  // ĐĂNG NHẬP THÀNH CÔNG: Hiện popup cảnh báo trước khi vào App
                  _showExpiryDialogIfNeeded(context);
                } else if (!success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sai tài khoản hoặc mật khẩu!'))
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
              child: const Text('ĐĂNG NHẬP', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegister() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Họ tên', prefixIcon: Icon(Icons.person))),
          const SizedBox(height: 15),
          TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email))),
          const SizedBox(height: 15),
          TextField(controller: _passController, obscureText: true, decoration: const InputDecoration(labelText: 'Mật khẩu', prefixIcon: Icon(Icons.lock))),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                await Provider.of<AuthProvider>(context, listen: false)
                    .register(_nameController.text, _emailController.text, _passController.text);

                if (mounted) {
                  _showExpiryDialogIfNeeded(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
              child: const Text('TẠO TÀI KHOẢN', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}