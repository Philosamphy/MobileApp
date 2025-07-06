import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB8LkiZES6rBPzXjnfuhpxQySAgHsT7Xx0',
    appId: '1:170263747434:web:8088734b46d8b69763e313',
    messagingSenderId: '170263747434',
    projectId: 'certificate-bb7f6',
    authDomain: 'certificate-bb7f6.firebaseapp.com',
    storageBucket: 'certificate-bb7f6.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB8LkiZES6rBPzXjnfuhpxQySAgHsT7Xx0',
    appId: '1:170263747434:android:8088734b46d8b69763e313',
    messagingSenderId: '170263747434',
    projectId: 'certificate-bb7f6',
    storageBucket: 'certificate-bb7f6.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB8LkiZES6rBPzXjnfuhpxQySAgHsT7Xx0',
    appId: '1:170263747434:ios:8088734b46d8b69763e313',
    messagingSenderId: '170263747434',
    projectId: 'certificate-bb7f6',
    storageBucket: 'certificate-bb7f6.firebasestorage.app',
    androidClientId:
        '170263747434-aardcpdtenc1iol91c3453c2ba0q56a5.apps.googleusercontent.com',
    iosClientId:
        '170263747434-aardcpdtenc1iol91c3453c2ba0q56a5.apps.googleusercontent.com',
    iosBundleId: 'com.example.certificate',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB8LkiZES6rBPzXjnfuhpxQySAgHsT7Xx0',
    appId: '1:170263747434:macos:8088734b46d8b69763e313',
    messagingSenderId: '170263747434',
    projectId: 'certificate-bb7f6',
    storageBucket: 'certificate-bb7f6.firebasestorage.app',
    iosClientId:
        '170263747434-aardcpdtenc1iol91c3453c2ba0q56a5.apps.googleusercontent.com',
    iosBundleId: 'com.example.certificate',
  );
}
