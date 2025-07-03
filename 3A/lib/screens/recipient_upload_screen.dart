import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_selector/file_selector.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../services/auth_service.dart';

class RecipientUploadScreen extends StatefulWidget {
  const RecipientUploadScreen({super.key});

  @override
  State<RecipientUploadScreen> createState() => _RecipientUploadScreenState();
}

class _RecipientUploadScreenState extends State<RecipientUploadScreen> {
  File? _selectedFile;
  String? _fileName;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null && pickedFile.path.isNotEmpty) {
        setState(() {
          _selectedFile = File(pickedFile.path);
          _fileName = pickedFile.name;
        });
      }
    } catch (e) {
      print('Image picker error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  Future<void> _pickPdf() async {
    try {
      const XTypeGroup typeGroup = XTypeGroup(
        label: 'PDFs',
        extensions: <String>['pdf'],
      );
      final XFile? file = await openFile(
        acceptedTypeGroups: <XTypeGroup>[typeGroup],
      );
      if (file != null && file.path.isNotEmpty) {
        setState(() {
          _selectedFile = File(file.path);
          _fileName = file.name;
        });
      }
    } catch (e) {
      print('PDF picker error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking PDF: $e')));
      }
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedFile = null;
      _fileName = null;
    });
  }

  Future<void> _submitUpload() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file to upload.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = Provider.of<AuthService>(context, listen: false).currentUser;
      if (user == null) throw Exception('User not logged in');

      // Upload file to Firebase Storage
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${_fileName}';
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('uploaded_documents')
          .child(user.uid)
          .child(fileName);

      final uploadTask = await storageRef.putFile(_selectedFile!);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Save metadata to Firestore with actual file URL
      final docId = const Uuid().v4();
      await FirebaseFirestore.instance
          .collection('uploaded_documents')
          .doc(docId)
          .set({
            'id': docId,
            'recipientId': user.uid,
            'recipientEmail': user.email,
            'senderName': user.displayName ?? 'Unknown User',
            'senderEmail': user.email,
            'fileName': _fileName,
            'fileUrl': downloadUrl,
            'fileType': _fileName?.split('.').last.toLowerCase(),
            'uploadedAt': FieldValue.serverTimestamp(),
            'uploadedAtLocal': DateTime.now().toIso8601String(),
            'status': 'pending_review',
            'storagePath': storageRef.fullPath,
            'fileSize': await _selectedFile!.length(),
          });

      if (mounted) {
        // Show success message with sender info
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'File uploaded successfully by ${user.displayName ?? user.email}!',
            ),
            duration: const Duration(seconds: 3),
          ),
        );

        // Navigate back to home page like CA does
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      print('Upload error: $e'); // Debug log
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading file: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Document')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _isLoading
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_selectedFile == null) ...[
                      ElevatedButton.icon(
                        icon: const Icon(Icons.image),
                        label: const Text('Upload Image (JPG, PNG)'),
                        onPressed: _pickImage,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text('Upload PDF'),
                        onPressed: _pickPdf,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ] else ...[
                      Card(
                        child: ListTile(
                          leading: Icon(
                            _fileName!.toLowerCase().endsWith('pdf')
                                ? Icons.picture_as_pdf
                                : Icons.image,
                          ),
                          title: const Text('Selected File'),
                          subtitle: Text(_fileName ?? ''),
                          trailing: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: _clearSelection,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _submitUpload,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.green,
                        ),
                        child: const Text('Submit for Review'),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}
