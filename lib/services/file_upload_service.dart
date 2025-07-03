import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class FileUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadFile(File file, String folder) async {
    try {
      final fileName =
          DateTime.now().millisecondsSinceEpoch.toString() +
          '_' +
          file.path.split('/').last;
      final ref = _storage.ref().child('$folder/$fileName');
      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      print('File upload error: $e');
      return null;
    }
  }
}
