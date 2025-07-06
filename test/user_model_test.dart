import 'package:flutter_test/flutter_test.dart';
import 'package:certificate/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  test('UserModel fromJson and toJson', () {
    final now = DateTime.now();
    final ts = Timestamp.fromDate(now);
    final json = {
      'id': '1',
      'uid': 'u1',
      'email': 'test@upm.edu.my',
      'displayName': 'Test User',
      'photoUrl': 'url',
      'phoneNumber': '123',
      'role': 'admin',
      'isActive': true,
      'createdAt': ts,
      'updatedAt': ts,
      'lastLoginAt': ts,
    };
    final user = UserModel.fromJson(json);
    expect(user.uid, 'u1');
    expect(user.isAdmin, true);
    final toJson = user.toJson();
    expect(toJson['email'], 'test@upm.edu.my');
    expect(toJson['role'], 'admin');
  });

  test('UserModel fromMap with missing fields', () {
    final now = DateTime.now();
    final ts = Timestamp.fromDate(now);
    final map = {
      'uid': 'u2',
      'email': 'a@b.com',
      'role': 'viewer',
      'createdAt': ts,
      'updatedAt': ts,
    };
    final user = UserModel.fromMap(map, 'docid');
    expect(user.id, 'docid');
    expect(user.role, 'viewer');
    expect(user.displayName, isNull);
  });
}
