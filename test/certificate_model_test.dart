import 'package:flutter_test/flutter_test.dart';
import 'package:certificate/models/certificate_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';

class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  test('CertificateModel fromFirestore and toMap', () {
    final now = DateTime.now();
    final ts = Timestamp.fromDate(now);
    final data = {
      'title': 'Cert',
      'recipientId': 'rid',
      'recipientName': 'n',
      'recipientEmail': 'e',
      'organization': 'o',
      'purpose': 'p',
      'issuedDate': ts,
      'expiryDate': ts,
      'issuerId': 'iid',
      'issuerName': 'i',
      'status': 'issued',
      'createdAt': ts,
    };
    final mockDoc = MockDocumentSnapshot();
    when(mockDoc.id).thenReturn('docid');
    when(mockDoc.data()).thenReturn(data);
    final cert = CertificateModel.fromFirestore(mockDoc);
    expect(cert.id, 'docid');
    expect(cert.title, 'Cert');
    final toMap = cert.toMap();
    expect(toMap['title'], 'Cert');
    expect(toMap['issuerId'], 'iid');
  });

  test('CertificateModel copyWith', () {
    final now = DateTime.now();
    final cert = CertificateModel(
      id: 'id',
      title: 't',
      recipientId: 'rid',
      recipientName: 'n',
      recipientEmail: 'e',
      organization: 'o',
      purpose: 'p',
      issuedDate: now,
      expiryDate: now,
      issuerId: 'iid',
      issuerName: 'i',
      status: CertificateStatus.issued,
      createdAt: now,
    );
    final cert2 = cert.copyWith(title: 'new');
    expect(cert2.title, 'new');
    expect(cert2.id, 'id');
  });
}
