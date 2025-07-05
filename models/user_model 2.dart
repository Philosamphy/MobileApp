import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { admin, certificateAuthority, recipient, viewer, client }

class UserModel {
  final String id;
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? phoneNumber;
  final String role;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLoginAt;

  UserModel({
    required this.id,
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.phoneNumber,
    required this.role,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
  });

  bool get isCA => role == 'ca';
  bool get isAdmin => role == 'admin';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'],
      photoUrl: json['photoUrl'],
      phoneNumber: json['phoneNumber'],
      role: json['role'] ?? 'viewer',
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
      lastLoginAt: json['lastLoginAt'] != null
          ? (json['lastLoginAt'] as Timestamp).toDate()
          : null,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      id: documentId,
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoUrl: data['photoUrl'],
      phoneNumber: data['phoneNumber'],
      role: data['role'] ?? 'viewer',
      isActive: data['isActive'] ?? true,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      lastLoginAt: data['lastLoginAt'] != null
          ? (data['lastLoginAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'role': role,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'lastLoginAt': lastLoginAt,
    };
  }
}
