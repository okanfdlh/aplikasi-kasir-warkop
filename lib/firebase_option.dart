// File: lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "YOUR_WEB_API_KEY",
    appId: "YOUR_WEB_APP_ID",
    messagingSenderId: "YOUR_SENDER_ID",
    projectId: "YOUR_PROJECT_ID",
    authDomain: "YOUR_PROJECT_ID.firebaseapp.com",
    storageBucket: "YOUR_PROJECT_ID.appspot.com",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyDnljdI-NGpt8rQ_bGvfezzqlzO12bYFfo",
    appId: "1:884746623818:android:39b429416a20c07b417fb3",
    messagingSenderId: "884746623818",
    projectId: "coffeeorderapp-f2248",
    storageBucket: "coffeeorderapp-f2248.firebasestorage.app",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "YOUR_IOS_API_KEY",
    appId: "1:1234567890:ios:abc123def456",
    messagingSenderId: "1234567890",
    projectId: "your-project-id",
    storageBucket: "your-project-id.appspot.com",
    iosClientId: "YOUR_IOS_CLIENT_ID",
    iosBundleId: "com.example.app",
  );
}
