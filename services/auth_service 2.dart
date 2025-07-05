import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
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
  bool _isLoggedIn = false;

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  UserModel? get currentUser => _currentUser;

  AuthService() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _isLoading = true;
    notifyListeners();
    if (user == null) {
      _currentUser = null;
      _isLoggedIn = false;
    } else {
      // Read role from database
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      String role = 'viewer';
      if (userDoc.exists) {
        role = userDoc.data()?['role'] ?? 'viewer';
        if (role == 'client') {
          final profileDoc = await _firestore
              .collection('client_profiles')
              .doc(user.uid)
              .get();
          if (!profileDoc.exists) {
            await _firestore.collection('client_profiles').doc(user.uid).set({
              'email': user.email,
              'displayName': user.displayName,
              'createdAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }
        }
      }
      _currentUser = UserModel(
        id: user.uid,
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
        photoUrl: user.photoURL,
        role: role,
      );
      _isLoggedIn = true;
    }
    _isLoading = false;
    notifyListeners();
  }

  // Google Sign-In
  Future<bool> signInWithGoogle() async {
    try {
      _isLoading = true;
      notifyListeners();
      print('Starting Google Sign In process...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('Google Sign In was cancelled by user');
        return false;
      }
      print('Google Sign In successful for: ${googleUser.email}');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      print('Got authentication tokens');
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      print('Signing in to Firebase with Google credential...');
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final user = userCredential.user;
      if (user == null) {
        print('Firebase sign in failed - no user returned');
        return false;
      }
      print('Firebase sign in successful for: ${user.email}');
      // Check if user exists in Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (!userDoc.exists) {
        print('Creating new user in Firestore');
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': user.email,
          'displayName': user.displayName,
          'photoURL': user.photoURL,
          'role': 'recipient',
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        print('User already exists in Firestore');
      }
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'lastLoginAt': FieldValue.serverTimestamp()},
      );
      final updatedUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final actualRole = updatedUserDoc.data()?['role'] ?? 'recipient';
      _currentUser = UserModel(
        id: user.uid,
        uid: user.uid,
        email: user.email!,
        displayName: user.displayName ?? '',
        photoUrl: user.photoURL,
        role: actualRole,
      );
      _isLoggedIn = true;
      notifyListeners();
      print('Google Sign In process completed successfully');
      return true;
    } catch (e) {
      print('Error signing in with Google: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  // Get user role
  Future<UserRole?> getUserRole(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        // Read role from database
        final role = doc.data()?['role'] as String?;
        return _stringToRole(role);
      }
      return null;
    } catch (e) {
      print('Error getting user role: $e');
      return null;
    }
  }

  // Update user role
  Future<void> updateUserRole(String userId, UserRole newRole) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': newRole.toString().split('.').last,
      });

      // Add log entry
      await _firestore.collection('logs').add({
        'action': 'role_created',
        'userId': userId,
        'newRole': newRole.toString().split('.').last,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating user role: $e');
      rethrow;
    }
  }

  UserRole _stringToRole(String? role) {
    if (role == null) {
      return UserRole.viewer;
    }

    switch (role.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'ca':
      case 'certificateauthority':
        return UserRole.certificateAuthority;
      case 'recipient':
        return UserRole.recipient;
      case 'client':
        return UserRole.client;
      case 'viewer':
        return UserRole.viewer;
      default:
        return UserRole.viewer;
    }
  }
}
