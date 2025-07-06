import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../models/document_model.dart';

class CertificateService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = Uuid();

  // Get all certificates
  Future<List<DocumentModel>> getAllCertificates() async {
    try {
      final querySnapshot = await _firestore.collection('certificates').get();
      return querySnapshot.docs
          .map((doc) => DocumentModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting certificates: $e');
      return [];
    }
  }

  // Get certificate by ID
  Future<DocumentModel?> getCertificateById(String id) async {
    try {
      final doc = await _firestore.collection('certificates').doc(id).get();
      if (doc.exists) {
        return DocumentModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting certificate: $e');
      return null;
    }
  }

  // Create new certificate
  Future<String?> createCertificate(DocumentModel certificate) async {
    try {
      final docRef = await _firestore
          .collection('certificates')
          .add(certificate.toMap());
      return docRef.id;
    } catch (e) {
      print('Error creating certificate: $e');
      return null;
    }
  }

  Future<void> updateCertificate(DocumentModel certificate) async {
    try {
      await _firestore
          .collection('certificates')
          .doc(certificate.id)
          .update(certificate.toMap());
    } catch (e) {
      print('Error updating certificate: $e');
      rethrow;
    }
  }

  // Update certificate
  Future<bool> updateCertificateStatus(String id, String status) async {
    try {
      await _firestore.collection('certificates').doc(id).update({
        'status': status,
      });
      return true;
    } catch (e) {
      print('Error updating certificate status: $e');
      return false;
    }
  }

  // Delete certificate
  Future<bool> deleteCertificate(String id) async {
    try {
      // Delete stored files
      final doc = await _firestore.collection('certificates').doc(id).get();
      if (doc.exists) {
        final data = doc.data()!;
        if (data['certificateUrl'] != null) {
          // TODO: Delete file from storage
        }
        if (data['signatureUrl'] != null) {
          // TODO: Delete file from storage
        }
      }

      // Delete Firestore document
      await _firestore.collection('certificates').doc(id).delete();
      return true;
    } catch (e) {
      print('Error deleting certificate: $e');
      return false;
    }
  }

  // Update certificate file URL
  Future<bool> updateCertificateFileUrl(String id, String fileUrl) async {
    try {
      await _firestore.collection('certificates').doc(id).update({
        'certificateUrl': fileUrl,
      });
      return true;
    } catch (e) {
      print('Error updating certificate file URL: $e');
      return false;
    }
  }

  // Get certificate by share token
  Future<DocumentModel?> getCertificateByShareToken(String token) async {
    try {
      final querySnapshot = await _firestore
          .collection('certificates')
          .where('shareToken', isEqualTo: token)
          .limit(1)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final certificate = DocumentModel.fromMap(doc.data());

        if (certificate.shareTokenCreatedAt != null) {
          final now = DateTime.now();
          final tokenAge = now.difference(certificate.shareTokenCreatedAt!);
          if (tokenAge.inDays >= 10) {
            // Token has expired
            return null;
          }
        }

        return certificate;
      }
      return null;
    } catch (e) {
      print('Error getting certificate by share token: $e');
      return null;
    }
  }
}
