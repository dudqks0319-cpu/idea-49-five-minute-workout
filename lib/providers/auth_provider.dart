import 'package:flutter/foundation.dart';

import '../services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({required this.service});

  final SupabaseService service;

  bool _loading = false;
  String? _error;

  bool get loading => _loading;
  String? get error => _error;
  bool get isLoggedIn => service.isLoggedIn;
  String? get userId => service.currentUserId;

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _error = null;
    notifyListeners();
    try {
      await service.signIn(email: email.trim(), password: password);
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUp(String email, String password) async {
    _setLoading(true);
    _error = null;
    notifyListeners();
    try {
      await service.signUp(email: email.trim(), password: password);
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    _error = null;
    notifyListeners();
    try {
      await service.signOut();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    service.dispose();
    super.dispose();
  }
}
