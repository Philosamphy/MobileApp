import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class RoleService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 角色权限映射
  final Map<String, List<String>> _rolePermissions = {
    'admin': [
      'manage_users',
      'manage_roles',
      'view_users',
      'manage_ca',
      'view_logs',
      'manage_settings',
      'issue_cert',
      'approve_cert',
      'view_cert',
      'share_cert',
      'request_cert',
    ],
    'ca': [
      'issue_cert',
      'approve_cert',
      'view_cert',
      'share_cert',
      'view_users',
    ],
    'client': ['request_cert', 'approve_cert', 'view_cert', 'share_cert'],
    'recipient': ['view_cert', 'share_cert'],
    'viewer': ['view_cert'],
  };

  final Map<String, String> _roleDescriptions = {
    'admin': 'System administrator, has all permissions',
    'ca':
        'Certificate Authority, responsible for issuing and managing certificates',
    'client': 'Client user, can request and approve certificates',
    'recipient': 'Certificate recipient, can view and share certificates',
    'viewer': 'Read-only user, can only view certificates',
  };

  Future<List<UserModel>> getAllUsers() async {
    try {
      final querySnapshot = await _firestore.collection('users').get();
      return querySnapshot.docs
          .map((doc) => UserModel.fromJson({...doc.data(), 'uid': doc.id}))
          .toList();
    } catch (e) {
      print('Failed to get all users: $e');
      return [];
    }
  }

  Future<void> updateUserRole(String uid, String role) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'role': role,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      await _firestore.collection('logs').add({
        'action': 'role_update',
        'userId': uid,
        'newRole': role,
        'timestamp': FieldValue.serverTimestamp(),
      });
      notifyListeners();
    } catch (e) {
      print('Failed to update user role: $e');
      throw Exception('Failed to update user role: $e');
    }
  }

  List<String> getAvailableRoles() {
    return _rolePermissions.keys.toList();
  }

  String getRoleDescription(String role) {
    return _roleDescriptions[role] ?? '';
  }

  List<String> getRolePermissionList(String role) {
    return _rolePermissions[role] ?? [];
  }
}
