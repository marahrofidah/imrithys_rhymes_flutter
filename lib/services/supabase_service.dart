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
}
