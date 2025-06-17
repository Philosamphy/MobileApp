import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { admin, certificateAuthority, recipient, viewer }

class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String role;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.role,
  });

  bool get isCA => role == 'ca';
  bool get isAdmin => role == 'admin';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'],
      photoUrl: json['photoUrl'],
      role: json['role'] ?? 'viewer',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'role': role,
    };
  }
}
