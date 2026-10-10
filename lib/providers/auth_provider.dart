import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  AuthProvider() {
    _authService.authStateChanges.listen((state) async {
      final user = state.session?.user;
      if (user != null) {
        _currentUser = await _authService.getUser(user.id);
      } else {
        _currentUser = null;
      }
      notifyListeners();
    });
    final current = _authService.currentUser;
    if (current != null) {
      _authService.getUser(current.id).then((u) {
        _currentUser = u;
        notifyListeners();
      });
    }
  }

  Future<void> signIn(String email, String password) async {
    _currentUser = await _authService.signIn(email, password);
    notifyListeners();
  }

  Future<void> register(String email, String password, String username) async {
    _currentUser = await _authService.register(email, password, username);
    notifyListeners();
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    notifyListeners();
  }
}
