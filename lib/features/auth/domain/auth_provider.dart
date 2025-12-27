import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  bool _isLoading = false;

  AuthProvider() {
    // Lắng nghe trạng thái đăng nhập thay đổi (Session)
    _auth.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isLoading => _isLoading;

  // Đăng ký tài khoản mới
  Future<String?> register(String email, String password, String name) async {
    _isLoading = true;
    notifyListeners();
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await result.user?.updateDisplayName(name);
      _isLoading = false;
      return null; // Thành công
    } catch (e) {
      _isLoading = false;
      return e.toString();
    }
  }

  // Đăng nhập
  Future<String?> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _isLoading = false;
      return null;
    } catch (e) {
      _isLoading = false;
      return e.toString();
    }
  }

  // Đăng xuất
  Future<void> logout() async {
    await _auth.signOut();
  }
}