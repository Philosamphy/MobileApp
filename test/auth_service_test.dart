import 'package:flutter_test/flutter_test.dart';
import 'package:certificate/services/auth_service.dart';
import 'package:certificate/models/user_model.dart';
import 'package:mockito/mockito.dart';
import 'mock_firebase.mocks.dart';
import 'package:mockito/annotations.dart';

void main() {
  late MockFirebaseAuth mockAuth;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockFirebaseFirestore mockFirestore;
  late AuthService authService;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockGoogleSignIn = MockGoogleSignIn();
    mockFirestore = MockFirebaseFirestore();
    when(mockAuth.authStateChanges()).thenAnswer((_) => const Stream.empty());

    final mockCollection = MockCollectionReference<Map<String, dynamic>>();
    when(mockFirestore.collection('users')).thenReturn(mockCollection);
    final mockDocRef = MockDocumentReference<Map<String, dynamic>>();
    when(mockCollection.doc(any)).thenReturn(mockDocRef);
    final mockDocSnap = MockDocumentSnapshot<Map<String, dynamic>>();
    when(mockDocRef.get()).thenAnswer((_) async => mockDocSnap);
    when(mockDocSnap.exists).thenReturn(false);

    authService = AuthService(
      auth: mockAuth,
      googleSignIn: mockGoogleSignIn,
      firestore: mockFirestore,
    );
  });

  test('isLoading and isLoggedIn default values', () {
    expect(authService.isLoading, isFalse);
    expect(authService.isLoggedIn, isFalse);
  });

  // 这里只做简单mock，不测试真实Google登录流程
  test('signInWithGoogle returns false if cancelled or error', () async {
    // 你可以根据需要mock signIn的行为
    when(mockGoogleSignIn.signIn()).thenAnswer((_) async => null);
    final result = await authService.signInWithGoogle();
    expect(result, isFalse);
  });

  test('signOut does not throw', () async {
    when(mockAuth.signOut()).thenAnswer((_) async => null);
    when(mockGoogleSignIn.signOut()).thenAnswer((_) async => null);
    await authService.signOut();
    expect(authService.isLoggedIn, isFalse);
  });

  test('getUserRole returns null if user not exist', () async {
    final mockDocRef = MockDocumentReference<Map<String, dynamic>>();
    final mockDocSnap = MockDocumentSnapshot<Map<String, dynamic>>();
    when(
      mockFirestore.collection('users'),
    ).thenReturn(MockCollectionReference<Map<String, dynamic>>());
    when(mockFirestore.collection('users').doc(any)).thenReturn(mockDocRef);
    when(mockDocRef.get()).thenAnswer((_) async => mockDocSnap);
    when(mockDocSnap.exists).thenReturn(false);
    final result = await authService.getUserRole('not_exist_uid');
    expect(result, isNull);
  });
}
