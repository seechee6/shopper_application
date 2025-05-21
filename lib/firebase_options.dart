// File created to provide default Firebase options
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'iOS is not configured yet. Please run flutterfire configure.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'macOS is not configured yet. Please run flutterfire configure.',
        );
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'Linux is not configured yet. Please run flutterfire configure.',
        );
      default:
        throw UnsupportedError('The current platform is not supported.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDFJTEy4-LiW2_pZg0jgfwWS0ZyyL6OsTo',
    appId: '1:99002182038:android:3a3b5876d9b4a663a655b7',
    messagingSenderId: '99002182038',
    projectId: 'shopper-application-c5467',
    storageBucket: 'shopper-application-c5467.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC2-fEf8Pk2zPZI8Pw6hf-SafUDD9r8JP4',
    appId: '1:99002182038:web:cd762b8606c78857a655b7',
    messagingSenderId: '99002182038',
    projectId: 'shopper-application-c5467',
    authDomain: 'shopper-application-c5467.firebaseapp.com',
    storageBucket: 'shopper-application-c5467.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC2-fEf8Pk2zPZI8Pw6hf-SafUDD9r8JP4',
    appId: '1:99002182038:web:b4df47eb9f1974a3a655b7',
    messagingSenderId: '99002182038',
    projectId: 'shopper-application-c5467',
    authDomain: 'shopper-application-c5467.firebaseapp.com',
    storageBucket: 'shopper-application-c5467.firebasestorage.app',
  );
}
