import 'package:cloud_firestore/cloud_firestore.dart';

class FileModel {
  final String id;
  final String filename;
  final String uploader;
  final String uploadDate;
  final String status;

  FileModel({
    required this.id,
    required this.filename,
    required this.uploader,
    required this.uploadDate,
    required this.status,
  });

  factory FileModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FileModel(
      id: doc.id,
      filename: data['filename'] ?? '',
      uploader: data['uploader'] ?? '',
      uploadDate: data['uploadDate'] ?? '',
      status: data['status'] ?? '',
    );
  }
  bool isValid() {
    final filenameOk = filename.isNotEmpty && filename.endsWith('.pdf');
    final uploaderOk = uploader.isNotEmpty && uploader.length >= 3;
    final dateOk = RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(uploadDate);

    return filenameOk && uploaderOk && dateOk;
  }

}

