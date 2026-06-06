class ClassModel {
  final String id;
  final String code;
  final String name;
  final String teacherId;
  final String? description;
  final DateTime createdAt;

  ClassModel({
    required this.id,
    required this.code,
    required this.name,
    required this.teacherId,
    this.description,
    required this.createdAt,
  });

  // Convert dari JSON (dari Supabase)
  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      teacherId: json['teacher_id'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // Convert ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'teacher_id': teacherId,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
