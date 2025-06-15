import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/document_model.dart';
import '../models/user_model.dart';

class DashboardService extends ChangeNotifier {
  List<DocumentModel> _documents = [];
  bool _isLoading = false;
  String? _error;

  List<DocumentModel> get documents => _documents;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUserDocuments(UserModel user) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('certificates')
          .orderBy('createdAt', descending: true)
          .get();

      _documents = querySnapshot.docs
          .map((doc) => DocumentModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createDocument(DocumentModel document) async {
    try {
      await FirebaseFirestore.instance
          .collection('certificates')
          .doc(document.id)
          .set(document.toMap());

      _documents.insert(0, document);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateDocument(DocumentModel document) async {
    try {
      await FirebaseFirestore.instance
          .collection('certificates')
          .doc(document.id)
          .update(document.toMap());

      final index = _documents.indexWhere((doc) => doc.id == document.id);
      if (index != -1) {
        _documents[index] = document;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteDocument(String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('certificates')
          .doc(documentId)
          .delete();

      _documents.removeWhere((doc) => doc.id == documentId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<String> generateShareToken(String documentId) async {
    try {
      final document = await FirebaseFirestore.instance
          .collection('certificates')
          .doc(documentId)
          .get();

      if (!document.exists) {
        throw Exception('Document not found');
      }

      final data = document.data() as Map<String, dynamic>;
      return data['shareToken'] as String? ?? '';
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
