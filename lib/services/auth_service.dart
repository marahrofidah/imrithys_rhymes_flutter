import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
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

  // ========== STUDY MODE ==========

  bool get isClassMode => _prefs.getBool('is_class_mode') ?? false;

  Future<void> setClassMode(bool value) async {
    await _prefs.setBool('is_class_mode', value);
  }

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

  // ========== LOCAL (MANDIRI) PROGRESS METHODS ==========

  Future<int> getLocalStreakCount(String userId) async {
    return _prefs.getInt('mandiri_streak_count_$userId') ?? 0;
  }

  Future<bool> checkAndResetLocalStreak(String userId) async {
    final streakCount = _prefs.getInt('mandiri_streak_count_$userId') ?? 0;
    if (streakCount == 0) return false;

    final lastActiveDateStr = _prefs.getString('mandiri_last_active_date_$userId');
    if (lastActiveDateStr == null) return false;

    try {
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      final yesterdayStart = todayStart.subtract(const Duration(days: 1));

      final lastActive = DateTime.parse(lastActiveDateStr);
      final lastActiveStart = DateTime(lastActive.year, lastActive.month, lastActive.day);

      if (lastActiveStart.isBefore(yesterdayStart)) {
        await _prefs.setInt('mandiri_streak_count_$userId', 0);
        return true;
      }
    } catch (e) {
      debugPrint('Error checking local streak: $e');
    }
    return false;
  }

  Future<bool> updateLocalStreakIfNeeded(String userId) async {
    final counts = await getLocalTodayListeningCounts(userId);
    final hasCompletedBab = counts.values.any((c) => c >= 5);
    if (!hasCompletedBab) return false;

    final today = DateTime.now();
    final todayDate = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final lastActiveDate = _prefs.getString('mandiri_last_active_date_$userId');
    if (lastActiveDate == todayDate) {
      return false;
    }

    final currentStreak = _prefs.getInt('mandiri_streak_count_$userId') ?? 0;
    final newStreak = currentStreak + 1;

    await _prefs.setInt('mandiri_streak_count_$userId', newStreak);
    await _prefs.setString('mandiri_last_active_date_$userId', todayDate);
    return true;
  }

  Future<Map<String, int>> getLocalTodayListeningCounts(String userId) async {
    final logsJson = _prefs.getString('mandiri_listening_logs_$userId');
    if (logsJson == null) return {};

    try {
      final List<dynamic> list = jsonDecode(logsJson);
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      final Map<String, int> counts = {};
      for (final item in list) {
        final map = item as Map<String, dynamic>;
        final listenedAtStr = map['listened_at'] as String;
        final listenedAt = DateTime.parse(listenedAtStr).toLocal();

        if (listenedAt.isAfter(todayStart) && listenedAt.isBefore(todayEnd)) {
          final key = map['bab_key'] as String;
          counts[key] = (counts[key] ?? 0) + 1;
        }
      }
      return counts;
    } catch (e) {
      debugPrint('Error parsing local listening logs: $e');
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> getLocalTodayTopBabs(String userId, {int limit = 3}) async {
    final logsJson = _prefs.getString('mandiri_listening_logs_$userId');
    if (logsJson == null) return [];

    try {
      final List<dynamic> list = jsonDecode(logsJson);
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      // Calculate counts and get labels
      final Map<String, Map<String, dynamic>> babMap = {};
      for (final item in list) {
        final map = item as Map<String, dynamic>;
        final listenedAtStr = map['listened_at'] as String;
        final listenedAt = DateTime.parse(listenedAtStr).toLocal();

        if (listenedAt.isAfter(todayStart) && listenedAt.isBefore(todayEnd)) {
          final key = map['bab_key'] as String;
          final label = map['bab_label'] as String;
          if (!babMap.containsKey(key)) {
            babMap[key] = {'babKey': key, 'babLabel': label, 'count': 0};
          }
          babMap[key]!['count'] = (babMap[key]!['count'] as int) + 1;
        }
      }

      final sorted = babMap.values.toList()
        ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

      return sorted.take(limit).toList();
    } catch (e) {
      debugPrint('Error parsing local top babs: $e');
      return [];
    }
  }

  Future<void> recordLocalListening(String userId, String babKey, String babLabel) async {
    final logsJson = _prefs.getString('mandiri_listening_logs_$userId');
    List<dynamic> list = [];
    if (logsJson != null) {
      try {
        list = jsonDecode(logsJson);
      } catch (_) {}
    }

    list.add({
      'bab_key': babKey,
      'bab_label': babLabel,
      'listened_at': DateTime.now().toUtc().toIso8601String(),
    });

    await _prefs.setString('mandiri_listening_logs_$userId', jsonEncode(list));
  }

  Future<Set<String>> getLocalPassedBabs(String userId) async {
    final passed = _prefs.getStringList('mandiri_passed_babs_$userId');
    return passed?.toSet() ?? {};
  }

  Future<List<Map<String, dynamic>>> getLocalQuizHistory(String userId) async {
    final historyJson = _prefs.getString('mandiri_quiz_history_$userId');
    if (historyJson == null) return [];
    try {
      final List<dynamic> list = jsonDecode(historyJson);
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveLocalQuizResult(
    String userId,
    String babKey,
    String babLabel,
    int babNumber,
    int score,
    int correctCount,
  ) async {
    // 1. Save to history
    final historyJson = _prefs.getString('mandiri_quiz_history_$userId');
    List<dynamic> history = [];
    if (historyJson != null) {
      try {
        history = jsonDecode(historyJson);
      } catch (_) {}
    }

    history.add({
      'bab_key': babKey,
      'bab_label': babLabel,
      'bab_number': babNumber,
      'score': score,
      'correct_count': correctCount,
      'is_passed': score >= 80,
      'attempted_at': DateTime.now().toUtc().toIso8601String(),
    });

    await _prefs.setString('mandiri_quiz_history_$userId', jsonEncode(history));

    // 2. Save to passed babs if score >= 80
    if (score >= 80) {
      final passedList = _prefs.getStringList('mandiri_passed_babs_$userId') ?? [];
      if (!passedList.contains(babKey)) {
        passedList.add(babKey);
        await _prefs.setStringList('mandiri_passed_babs_$userId', passedList);
      }
    }
  }
}
