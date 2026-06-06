import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';
import 'supabase_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  late SharedPreferences _prefs;
  UserModel? _currentUser;

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  // Initialize
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadStoredUser();
  }

  // ========== LOGIN / LOGOUT ==========

  Future<UserModel?> login(String usernameOrEmail, String password) async {
    final supabase = SupabaseService();
    final user = await supabase.login(usernameOrEmail, password);

    if (user != null) {
      _currentUser = user;
      await _saveUser(user);
      return user;
    }
    return null;
  }

  Future<void> logout() async {
    _currentUser = null;
    await _prefs.remove('current_user');
  }

  // ========== USER SESSION ==========

  UserModel? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null;

  bool get isTeacher => _currentUser?.isTeacher ?? false;

  bool get isStudent => _currentUser?.isStudent ?? false;

  // ========== PRIVATE METHODS ==========

  Future<void> _saveUser(UserModel user) async {
    final userJson = jsonEncode(user.toJson());
    await _prefs.setString('current_user', userJson);
  }

  Future<void> _loadStoredUser() async {
    final userJson = _prefs.getString('current_user');
    if (userJson != null) {
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      _currentUser = UserModel.fromJson(userMap);
    }
  }
}
