import 'package:flutter_test/flutter_test.dart';
import 'package:certificate/models/document_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  test('DocumentModel fromMap and toMap', () {
    final now = DateTime.now();
    final ts = Timestamp.fromDate(now);
    final map = {
      'id': 'doc1',
      'title': 'Cert',
      'recipientName': 'Alice',
      'recipientEmail': 'alice@upm.edu.my',
      'recipientId': 'r1',
      'issuerName': 'CA',
      'issuerId': 'ca1',
      'organization': 'UPM',
      'purpose': 'Test',
      'status': 'issued',
      'createdAt': ts,
      'issuedDate': ts,
      'expiryDate': ts,
    };
    final doc = DocumentModel.fromMap(map);
    expect(doc.id, 'doc1');
    expect(doc.title, 'Cert');
    final toMap = doc.toMap();
    expect(toMap['title'], 'Cert');
    expect(toMap['recipientEmail'], 'alice@upm.edu.my');
  });

  test('DocumentModel copyWith', () {
    final now = DateTime.now();
    final ts = Timestamp.fromDate(now);
    final doc = DocumentModel(
      id: 'id',
      title: 't',
      recipientName: 'n',
      recipientEmail: 'e',
      recipientId: 'rid',
      issuerName: 'i',
      issuerId: 'iid',
      organization: 'o',
      purpose: 'p',
      status: 's',
      createdAt: now,
      issuedDate: now,
      expiryDate: now,
    );
    final doc2 = doc.copyWith(title: 'new');
    expect(doc2.title, 'new');
    expect(doc2.id, 'id');
  });
}
