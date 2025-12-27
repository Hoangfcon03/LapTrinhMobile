import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// Import file cấu hình Firebase tự động tạo bởi FlutterFire CLI
import 'firebase_options.dart';

// --- IMPORT CÁC PROVIDERS ---
import 'package:bepthongminh64pm1duchoang/features/auth/domain/auth_provider.dart';
import 'package:bepthongminh64pm1duchoang/features/pantry/domain/pantry_provider.dart';
import 'package:bepthongminh64pm1duchoang/features/recipe/domain/recipe_provider.dart';
import 'package:bepthongminh64pm1duchoang/features/planner/domain/planner_provider.dart';
import 'package:bepthongminh64pm1duchoang/features/alerts/domain/alerts_provider.dart';

// --- IMPORT CÁC SCREENS ---
import 'package:bepthongminh64pm1duchoang/features/auth/presentation/screens/auth_screen.dart';
import 'package:bepthongminh64pm1duchoang/features/pantry/presentation/screens/pantry_screen.dart';
import 'package:bepthongminh64pm1duchoang/features/recipe/presentation/screens/recipe_list_screen.dart';
import 'package:bepthongminh64pm1duchoang/features/planner/presentation/screens/planner_screen.dart';
import 'package:bepthongminh64pm1duchoang/features/profile/presentation/screens/profile_screen.dart';

void main() async {
  // Đảm bảo Flutter framework được khởi tạo trước khi gọi Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase với các tùy chọn tương ứng với nền tảng (Android/iOS)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MultiProviderWrapper());
}

class MultiProviderWrapper extends StatelessWidget {
  const MultiProviderWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Khai báo tất cả các Provider quản lý trạng thái ứng dụng
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PantryProvider()),
        ChangeNotifierProvider(create: (_) => RecipeProvider()),
        ChangeNotifierProvider(create: (_) => PlannerProvider()),
        ChangeNotifierProvider(create: (_) => AlertsProvider()),
      ],
      child: MaterialApp(
        title: 'Bếp Trợ Lý Thông Minh',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4CAF50), // Màu xanh lá chủ đạo
            primary: const Color(0xFF4CAF50),
            secondary: const Color(0xFFFF9800), // Màu cam cảnh báo
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
        ),
        home: const AuthCheck(),
      ),
    );
  }
}

// Kiểm tra trạng thái đăng nhập để điều hướng người dùng
class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    // Lắng nghe trạng thái đăng nhập từ AuthProvider
    final auth = Provider.of<AuthProvider>(context);

    // Nếu đã có User (Firebase Auth), vào MainLayout, ngược lại vào màn hình Login
    return auth.isLoggedIn ? const MainLayout() : const AuthScreen();
  }
}

// Giao diện chính với Bottom Navigation Bar
class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  // Danh sách các màn hình chính
  final List<Widget> _screens = [
    const PantryScreen(),      // Tab 0: Kho
    const RecipeListScreen(),  // Tab 1: Công thức
    const PlannerScreen(),     // Tab 2: Kế hoạch
    const ProfileScreen(),     // Tab 3: Hồ sơ
  ];

  @override
  void initState() {
    super.initState();
    // Sau khi đăng nhập, tự động tải dữ liệu thực phẩm từ Cloud Firestore
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PantryProvider>(context, listen: false).fetchIngredients();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Dùng IndexedStack để giữ trạng thái các tab khi chuyển đổi (không load lại trang)
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'Kho'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'Công thức'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Kế hoạch'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Hồ sơ'),
        ],
      ),
    );
  }
}