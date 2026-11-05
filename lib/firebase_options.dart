import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return android;
    }

    throw UnsupportedError(
      'Firebase is not configured for this platform.',
    );
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyApNM4bjXWvYYy9VBnltu8G-rU1LobapK8',
    appId: '1:82833308407:android:3dfa103ff7e07d4bddf1f2',
    messagingSenderId: '82833308407',
    projectId: 'techshop-b8c03',
    storageBucket: 'techshop-b8c03.firebasestorage.app',
  );
}