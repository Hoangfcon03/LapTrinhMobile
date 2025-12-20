import 'package:flutter/material.dart';
import 'package:bepthongminh64pm1duchoang/features/auth/domain/user_model.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;

  // Giả lập Đăng nhập
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    // Giả lập delay API 1.5 giây
    await Future.delayed(const Duration(milliseconds: 1500));

    if (email.isNotEmpty && password.length >= 6) {
      _user = UserModel(id: '1', email: email, name: 'Người dùng Bếp');
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Đăng ký
  Future<void> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 2));
    _user = UserModel(id: '2', email: email, name: name);
    _isLoading = false;
    notifyListeners();
  }

  // Đăng xuất
  void logout() {
    _user = null;
    notifyListeners();
  }
}