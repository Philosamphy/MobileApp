import 'package:flutter/foundation.dart';

/// 用户模型类
@immutable
class User {
  final String id;
  final String email;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? name;
  final String? phone;
  final String? avatar;
  final bool isActive;
  final Map<String, dynamic>? metadata;

  const User({
    required this.id,
    required this.email,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    this.name,
    this.phone,
    this.avatar,
    this.isActive = true,
    this.metadata,
  });

  /// 从JSON创建用户对象
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'name': name,
      'phone': phone,
      'avatar': avatar,
      'isActive': isActive,
      'metadata': metadata,
    };
  }

  /// 创建副本
  User copyWith({
    String? id,
    String? email,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? name,
    String? phone,
    String? avatar,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
    );
  }

  /// 获取角色显示名称
  String get roleDisplayName {
    switch (role) {
      case 'admin':
        return '管理员';
      case 'manager':
        return '经理';
      case 'user':
        return '用户';
      default:
        return role;
    }
  }

  /// 获取角色颜色
  int get roleColor {
    switch (role) {
      case 'admin':
        return 0xFFE53935; // 红色
      case 'manager':
        return 0xFFFF9800; // 橙色
      case 'user':
        return 0xFF4CAF50; // 绿色
      default:
        return 0xFF9E9E9E; // 灰色
    }
  }

  /// 获取用户头像
  String get displayName {
    return name ?? email.split('@')[0];
  }

  /// 获取用户头像字母
  String get avatarLetter {
    return displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';
  }

  /// 检查用户是否为管理员
  bool get isAdmin => role == 'admin';

  /// 检查用户是否为经理
  bool get isManager => role == 'manager';

  /// 检查用户是否为普通用户
  bool get isRegularUser => role == 'user';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'User(id: $id, email: $email, role: $role)';
  }
}
