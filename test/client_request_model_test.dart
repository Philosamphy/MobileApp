import 'package:flutter_test/flutter_test.dart';
import 'package:certificate/models/client_request_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  test('ClientRequestModel fromMap and toMap', () {
    final now = DateTime.now();
    final ts = Timestamp.fromDate(now);
    final map = {
      'id': 'id1',
      'title': 'req',
      'email': 'test@upm.edu.my',
      'clientId': 'cid',
      'clientName': 'cname',
      'status': 'pending',
      'createdAt': ts,
      'updatedAt': ts,
      'notes': 'note',
    };
    final model = ClientRequestModel.fromMap(map);
    expect(model.id, 'id1');
    expect(model.title, 'req');
    expect(model.status, 'pending');
    final toMap = model.toMap();
    expect(toMap['clientId'], 'cid');
    expect(toMap['notes'], 'note');
  });

  test('ClientRequestModel copyWith', () {
    final now = DateTime.now();
    final model = ClientRequestModel(
      id: 'id',
      title: 't',
      email: 'e',
      clientId: 'cid',
      clientName: 'cname',
      status: 'pending',
      createdAt: now,
      updatedAt: now,
    );
    final model2 = model.copyWith(title: 'new');
    expect(model2.title, 'new');
    expect(model2.id, 'id');
  });
}
