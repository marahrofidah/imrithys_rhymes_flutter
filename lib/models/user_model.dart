class UserModel {
  final String id;
  final String email;
  final String username;
  final String role;
  final String? fullName;
  final String? gender; // 'laki-laki' atau 'perempuan'
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.role,
    this.fullName,
    this.gender,
    required this.createdAt,
  });

  // Convert dari JSON (dari Supabase)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      role: json['role'] as String,
      fullName: json['full_name'] as String?,
      gender: json['gender'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // Convert ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'role': role,
      'full_name': fullName,
      'gender': gender,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Helper untuk check role
  bool get isTeacher => role == 'teacher';
  bool get isStudent => role == 'student';
}
