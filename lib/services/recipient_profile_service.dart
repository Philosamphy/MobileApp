import 'package:cloud_firestore/cloud_firestore.dart';

class RecipientProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get recipient profile by user ID
  Future<Map<String, dynamic>?> getRecipientProfile(String userId) async {
    try {
      final doc = await _firestore
          .collection('recipient_profiles')
          .doc(userId)
          .get();

      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Error getting recipient profile: $e');
      return null;
    }
  }

  // Save or update recipient profile
  Future<bool> saveRecipientProfile(
    String userId,
    Map<String, dynamic> profileData,
  ) async {
    try {
      await _firestore.collection('recipient_profiles').doc(userId).set({
        ...profileData,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return true;
    } catch (e) {
      print('Error saving recipient profile: $e');
      return false;
    }
  }

  // Get all recipient profiles (for CA management)
  Future<List<Map<String, dynamic>>> getAllRecipientProfiles() async {
    try {
      final querySnapshot = await _firestore
          .collection('recipient_profiles')
          .orderBy('updatedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      print('Error getting all recipient profiles: $e');
      return [];
    }
  }

  // Update specific fields in recipient profile
  Future<bool> updateRecipientProfileField(
    String userId,
    String field,
    dynamic value,
  ) async {
    try {
      await _firestore.collection('recipient_profiles').doc(userId).update({
        field: value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating recipient profile field: $e');
      return false;
    }
  }

  // Delete recipient profile
  Future<bool> deleteRecipientProfile(String userId) async {
    try {
      await _firestore.collection('recipient_profiles').doc(userId).delete();
      return true;
    } catch (e) {
      print('Error deleting recipient profile: $e');
      return false;
    }
  }
}
