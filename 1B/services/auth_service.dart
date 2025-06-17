import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserModel? _currentUser;
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  UserModel? get currentUser => _currentUser;

  AuthService() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _isLoading = true;
    notifyListeners();
    if (user == null) {
      _currentUser = null;
    } else {
      // 读取数据库里的role
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      String role = 'viewer';
      if (userDoc.exists) {
        role = userDoc.data()?['role'] ?? 'viewer';
      }
      _currentUser = UserModel(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
        photoUrl: user.photoURL,
        role: role,
      );
    }
    _isLoading = false;
    notifyListeners();
  }

  // Google登录
  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final User? user = userCredential.user;

      if (user != null) {
        // 检查用户是否存在于Firestore
        final userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          // 创建新用户
          final newUser = UserModel(
            uid: user.uid,
            email: user.email!,
            displayName: user.displayName ?? '',
            photoUrl: user.photoURL,
            role: 'recipient', // 默认为接收者角色
          );

          await _firestore
              .collection('users')
              .doc(user.uid)
              .set(newUser.toJson());
          return newUser;
        } else {
          // 更新最后登录时间
          await _firestore.collection('users').doc(user.uid).update({
            'lastLogin': FieldValue.serverTimestamp(),
          });

          return UserModel.fromJson(userDoc.data()!);
        }
      }
      return null;
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    }
  }

  // 登出
  Future<void> signOut() async {
    try {
      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  // 获取用户角色
  Future<UserRole?> getUserRole(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        return UserRole.values.firstWhere(
          (e) => e.toString() == 'UserRole.${userData!['role']}',
          orElse: () => UserRole.viewer,
        );
      }
      return null;
    } catch (e) {
      print('Error getting user role: $e');
      return null;
    }
  }

  // 更新用户角色
  Future<void> updateUserRole(String userId, UserRole newRole) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': newRole.toString().split('.').last,
      });
    } catch (e) {
      print('Error updating user role: $e');
      rethrow;
    }
  }
}
