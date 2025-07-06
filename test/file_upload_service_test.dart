import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'mock_firebase.mocks.dart';
import 'package:certificate/services/file_upload_service.dart';
import 'dart:io';

void main() {
  late MockFirebaseStorage mockStorage;
  late FileUploadService fileUploadService;

  setUp(() {
    mockStorage = MockFirebaseStorage();
    fileUploadService = FileUploadService();
    // FileUploadService未做依赖注入，建议后续重构
  });

  test('uploadFile returns null on error', () async {
    final file = File('dummy.txt');
    // 这里无法mock putFile，建议重构FileUploadService支持依赖注入
    final result = await fileUploadService.uploadFile(file, 'folder');
    expect(result, isNull);
  });
}
