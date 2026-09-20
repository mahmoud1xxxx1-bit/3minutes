
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        throw UnsupportedError('DefaultFirebaseOptions have not been configured for windows.');
      case TargetPlatform.linux:
        throw UnsupportedError('DefaultFirebaseOptions have not been configured for linux.');
      default:
        throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBr386GNXJ2AQnrZNmS8qo7HBvbeCuDLII',
    appId: '1:492486855771:web:55d81b88c7657f0883037e',
    messagingSenderId: '492486855771',
    projectId: 'minutes-d7dfc',
    authDomain: 'minutes-d7dfc.firebaseapp.com',
    storageBucket: 'minutes-d7dfc.firebasestorage.app',
    measurementId: 'G-1Y66W3ZE28',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBr386GNXJ2AQnrZNmS8qo7HBvbeCuDLII', // Fallback, normally relies on google-services.json
    appId: '1:492486855771:android:7cbe840f5695f19883037e', // From previous screenshot
    messagingSenderId: '492486855771',
    projectId: 'minutes-d7dfc',
    storageBucket: 'minutes-d7dfc.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBr386GNXJ2AQnrZNmS8qo7HBvbeCuDLII',
    appId: '1:492486855771:ios:dummyiosappid',
    messagingSenderId: '492486855771',
    projectId: 'minutes-d7dfc',
    storageBucket: 'minutes-d7dfc.firebasestorage.app',
  );

  static const FirebaseOptions macos = ios;
}

