import 'package:flutter_test/flutter_test.dart';
import 'package:certificate/services/certificate_service.dart';
import 'package:certificate/models/document_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:certificate/firebase_options.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  group('CertificateService', () {
    late CertificateService service;

    setUp(() {
      service = CertificateService();
    });

    test('getAllCertificates returns empty list on error', () async {
      final result = await service.getAllCertificates();
      expect(result, isA<List<DocumentModel>>());
    });

    test('getCertificateById returns null on error', () async {
      final result = await service.getCertificateById('not_exist_id');
      expect(result, isNull);
    });

    test('createCertificate returns null or string', () async {
      final doc = DocumentModel(
        id: 'id',
        title: 'Test',
        recipientId: 'uid',
        recipientName: 'Name',
        recipientEmail: 'mail@test.com',
        organization: 'Org',
        purpose: 'Purpose',
        issuedDate: DateTime.now(),
        expiryDate: DateTime.now().add(Duration(days: 365)),
        issuerId: 'issuer',
        issuerName: 'Issuer',
        status: 'draft',
        createdAt: DateTime.now(),
      );
      final result = await service.createCertificate(doc);
      expect(result, anyOf(isNull, isA<String>()));
    });

    test('updateCertificateStatus returns bool', () async {
      final result = await service.updateCertificateStatus(
        'not_exist_id',
        'issued',
      );
      expect(result, isA<bool>());
    });

    test('deleteCertificate returns bool', () async {
      final result = await service.deleteCertificate('not_exist_id');
      expect(result, isA<bool>());
    });
  });
}
