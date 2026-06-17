import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/class_model.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  late SupabaseClient _client;

  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal();

  // Initialize Supabase
  Future<void> initialize() async {
    _client = Supabase.instance.client;
  }

  SupabaseClient get client => _client;

  // ========== AUTH METHODS ==========

  /// Login dengan username/email dan password
  Future<UserModel?> login(String usernameOrEmail, String password) async {
    try {
      final passwordHash = sha256.convert(password.codeUnits).toString();

      // Query user dari database
      final response = await _client
          .from('users')
          .select()
          .or('email.eq.$usernameOrEmail,username.eq.$usernameOrEmail')
          .maybeSingle();

      if (response == null) {
        throw Exception('User tidak ditemukan');
      }

      // Verifikasi password
      if (response['password_hash'] != passwordHash) {
        throw Exception('Password salah');
      }

      return UserModel.fromJson(response);
    } catch (e) {
      debugPrint('Login error: $e');
      return null;
    }
  }

  /// Register user baru
  Future<UserModel?> register(
    String email,
    String username,
    String password,
    String role, {
    String? fullName,
    String? gender,
  }) async {
    try {
      final passwordHash = sha256.convert(password.codeUnits).toString();

      final response = await _client
          .from('users')
          .insert({
            'email': email,
            'username': username,
            'password_hash': passwordHash,
            'role': role,
            'full_name': fullName,
            'gender': gender,
          })
          .select()
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      debugPrint('Register error: $e');
      return null;
    }
  }

  // ========== CLASS METHODS ==========

  /// Generate kode kelas acak 6 karakter (huruf kapital + angka)
  String _generateClassCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }

  /// Buat kelas baru untuk guru saat register
  Future<ClassModel?> createClassForTeacher(
    String teacherId,
    String teacherName,
  ) async {
    try {
      // Generate kode unik — coba sampai tidak bentrok
      String code;
      bool codeExists = true;
      do {
        code = _generateClassCode();
        final existing = await _client
            .from('classes')
            .select('id')
            .eq('code', code)
            .maybeSingle();
        codeExists = existing != null;
      } while (codeExists);

      final response = await _client
          .from('classes')
          .insert({
            'code': code,
            'name': 'Kelas $teacherName',
            'teacher_id': teacherId,
            'description': 'Kelas milik $teacherName',
          })
          .select()
          .single();

      return ClassModel.fromJson(response);
    } catch (e) {
      debugPrint('Create class error: $e');
      return null;
    }
  }

  /// Ambil kelas milik guru berdasarkan teacher_id
  Future<ClassModel?> getClassByTeacherId(String teacherId) async {
    try {
      final response = await _client
          .from('classes')
          .select()
          .eq('teacher_id', teacherId)
          .maybeSingle();

      if (response == null) return null;
      return ClassModel.fromJson(response);
    } catch (e) {
      debugPrint('Get class by teacher error: $e');
      return null;
    }
  }

  /// Cari class berdasarkan code
  Future<ClassModel?> getClassByCode(String code) async {
    try {
      final response = await _client
          .from('classes')
          .select()
          .eq('code', code)
          .maybeSingle();

      if (response == null) {
        throw Exception('Kelas dengan kode $code tidak ditemukan');
      }

      return ClassModel.fromJson(response);
    } catch (e) {
      debugPrint('Get class error: $e');
      return null;
    }
  }

  /// Enroll student ke class
  Future<bool> enrollStudentToClass(String studentId, String classId) async {
    try {
      await _client.from('student_enrollments').insert({
        'student_id': studentId,
        'class_id': classId,
      });
      return true;
    } catch (e) {
      debugPrint('Enroll error: $e');
      return false;
    }
  }

  /// Cek apakah murid sudah terdaftar di kelas manapun
  Future<bool> isStudentEnrolled(String studentId) async {
    try {
      final response = await _client
          .from('student_enrollments')
          .select('id')
          .eq('student_id', studentId)
          .maybeSingle();
      return response != null;
    } catch (e) {
      debugPrint('Check enrollment error: $e');
      return false;
    }
  }

  /// Ambil semua murid dalam kelas (join dengan tabel users)
  Future<List<Map<String, dynamic>>> getStudentsInClass(String classId) async {
    try {
      final response = await _client
          .from('student_enrollments')
          .select('student_id, users(id, full_name, username, gender)')
          .eq('class_id', classId);

      return (response as List)
          .map((e) => e['users'] as Map<String, dynamic>)
          .toList();
    } catch (e) {
      debugPrint('Get students in class error: $e');
      return [];
    }
  }

  /// Ambil semua class untuk student
  Future<List<ClassModel>> getStudentClasses(String studentId) async {
    try {
      final response = await _client
          .from('student_enrollments')
          .select(
            'class_id, classes(id, code, name, teacher_id, description, created_at)',
          )
          .eq('student_id', studentId);

      final classes = (response as List)
          .map((e) => ClassModel.fromJson(e['classes']))
          .toList();

      return classes;
    } catch (e) {
      debugPrint('Get student classes error: $e');
      return [];
    }
  }

  /// Ambil semua class untuk teacher
  Future<List<ClassModel>> getTeacherClasses(String teacherId) async {
    try {
      final response = await _client
          .from('classes')
          .select()
          .eq('teacher_id', teacherId);

      final classes = (response as List)
          .map((e) => ClassModel.fromJson(e))
          .toList();

      return classes;
    } catch (e) {
      debugPrint('Get teacher classes error: $e');
      return [];
    }
  }

  // ========== VALIDATION METHODS ==========

  /// Check apakah username sudah ada
  Future<bool> isUsernameExists(String username) async {
    try {
      final response = await _client
          .from('users')
          .select('id')
          .eq('username', username)
          .maybeSingle();

      return response != null;
    } catch (e) {
      debugPrint('Check username error: $e');
      return false;
    }
  }

  /// Check apakah email sudah ada
  Future<bool> isEmailExists(String email) async {
    try {
      final response = await _client
          .from('users')
          .select('id')
          .eq('email', email)
          .maybeSingle();

      return response != null;
    } catch (e) {
      debugPrint('Check email error: $e');
      return false;
    }
  }

  // ========== LISTENING & STREAK METHODS (TIKROR) ==========

  /// Catat satu kali mendengarkan audio selesai
  Future<void> recordListening({
    required String studentId,
    required String babKey,
    required String babLabel,
  }) async {
    try {
      await _client.from('listening_logs').insert({
        'student_id': studentId,
        'bab_key': babKey,
        'bab_label': babLabel,
        'listened_at': DateTime.now().toUtc().toIso8601String(),
      });
      debugPrint('Listening recorded: $babKey');
    } catch (e) {
      debugPrint('Record listening error: $e');
    }
  }

  /// Ambil jumlah tiap bab yang didengarkan hari ini
  /// Return: Map(babKey, count)
  Future<Map<String, int>> getTodayListeningCounts(String studentId) async {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day).toUtc();
      final todayEnd = todayStart.add(const Duration(days: 1));

      final response = await _client
          .from('listening_logs')
          .select('bab_key, bab_label')
          .eq('student_id', studentId)
          .gte('listened_at', todayStart.toIso8601String())
          .lt('listened_at', todayEnd.toIso8601String());

      final Map<String, int> counts = {};
      for (final row in response as List) {
        final key = row['bab_key'] as String;
        counts[key] = (counts[key] ?? 0) + 1;
      }
      return counts;
    } catch (e) {
      debugPrint('Get today listening counts error: $e');
      return {};
    }
  }

  /// Ambil top 3 bab yang paling banyak didengar hari ini
  /// Return: List of Map {babKey, babLabel, count}
  Future<List<Map<String, dynamic>>> getTodayTopBabs(
    String studentId, {
    int limit = 3,
  }) async {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day).toUtc();
      final todayEnd = todayStart.add(const Duration(days: 1));

      final response = await _client
          .from('listening_logs')
          .select('bab_key, bab_label')
          .eq('student_id', studentId)
          .gte('listened_at', todayStart.toIso8601String())
          .lt('listened_at', todayEnd.toIso8601String());

      // Hitung per bab
      final Map<String, Map<String, dynamic>> babMap = {};
      for (final row in response as List) {
        final key = row['bab_key'] as String;
        final label = row['bab_label'] as String;
        if (!babMap.containsKey(key)) {
          babMap[key] = {'babKey': key, 'babLabel': label, 'count': 0};
        }
        babMap[key]!['count'] = (babMap[key]!['count'] as int) + 1;
      }

      // Sort by count descending, ambil top N
      final sorted = babMap.values.toList()
        ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

      return sorted.take(limit).toList();
    } catch (e) {
      debugPrint('Get today top babs error: $e');
      return [];
    }
  }

  /// Ambil jumlah streak total murid
  Future<int> getStudentStreakCount(String studentId) async {
    try {
      final response = await _client
          .from('student_streaks')
          .select('streak_count')
          .eq('student_id', studentId)
          .maybeSingle();

      if (response == null) return 0;
      return (response['streak_count'] as int?) ?? 0;
    } catch (e) {
      debugPrint('Get streak error: $e');
      return 0;
    }
  }

  /// Update streak jika hari ini ada bab yang sudah didengar ≥ 5x
  /// Return true jika streak berhasil bertambah hari ini
  Future<bool> updateStreakIfNeeded(String studentId) async {
    try {
      // Ambil counts hari ini
      final counts = await getTodayListeningCounts(studentId);

      // Cek apakah ada bab yang sudah ≥ 5x
      final hasCompletedBab = counts.values.any((c) => c >= 5);
      if (!hasCompletedBab) return false;

      final today = DateTime.now();
      final todayDate =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      // Cek apakah streak sudah di-update hari ini
      final existing = await _client
          .from('student_streaks')
          .select()
          .eq('student_id', studentId)
          .maybeSingle();

      if (existing == null) {
        // Buat record baru
        await _client.from('student_streaks').insert({
          'student_id': studentId,
          'streak_count': 1,
          'last_active_date': todayDate,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        });
        return true;
      }

      final lastActiveDate = existing['last_active_date'] as String?;
      if (lastActiveDate == todayDate) {
        // Sudah di-update hari ini, jangan tambah lagi
        return false;
      }

      // Tambah streak count
      final newCount = (existing['streak_count'] as int) + 1;
      await _client
          .from('student_streaks')
          .update({
            'streak_count': newCount,
            'last_active_date': todayDate,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('student_id', studentId);

      return true;
    } catch (e) {
      debugPrint('Update streak error: $e');
      return false;
    }
  }
}
