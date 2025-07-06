import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

@GenerateMocks([
  FirebaseAuth,
  FirebaseFirestore,
  FirebaseStorage,
  GoogleSignIn,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
])
void main() {}
