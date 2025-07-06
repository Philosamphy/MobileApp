import 'package:flutter_test/flutter_test.dart';
import 'package:certificate/models/client_profile_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  test('ClientProfileModel fromMap and toMap', () {
    final now = DateTime.now();
    final ts = Timestamp.fromDate(now);
    final map = {
      'email': 'test@upm.edu.my',
      'displayName': 'Test',
      'phoneNumber': '123',
      'address': 'UPM',
      'description': 'desc',
      'createdAt': ts,
      'updatedAt': ts,
    };
    final model = ClientProfileModel.fromMap(map, 'id1');
    expect(model.id, 'id1');
    expect(model.email, 'test@upm.edu.my');
    final toMap = model.toMap();
    expect(toMap['address'], 'UPM');
    expect(toMap['description'], 'desc');
  });

  test('ClientProfileModel copyWith', () {
    final now = DateTime.now();
    final model = ClientProfileModel(
      id: 'id',
      email: 'e',
      displayName: 'n',
      phoneNumber: 'p',
      address: 'a',
      description: 'd',
      createdAt: now,
      updatedAt: now,
    );
    final model2 = model.copyWith(email: 'new@upm.edu.my');
    expect(model2.email, 'new@upm.edu.my');
    expect(model2.id, 'id');
  });
}
