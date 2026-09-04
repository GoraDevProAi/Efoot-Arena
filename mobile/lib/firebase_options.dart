// File generated for eFoot Arena
// Project ID: efoot-arena-c288b
// Android package: com.efootarena.app

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Web — à compléter quand tu ajouteras une app Web dans Firebase
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC4ktDvNXONFg5sHEC4yyG4EYnWmC42N6Q',
    appId: '1:895853704319:web:REPLACE_ME',
    messagingSenderId: '895853704319',
    projectId: 'efoot-arena-c288b',
    authDomain: 'efoot-arena-c288b.firebaseapp.com',
    storageBucket: 'efoot-arena-c288b.firebasestorage.app',
  );

  // Android — configuré depuis google-services.json
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC4ktDvNXONFg5sHEC4yyG4EYnWmC42N6Q',
    appId: '1:895853704319:android:04be7c304e6fde37273b4a',
    messagingSenderId: '895853704319',
    projectId: 'efoot-arena-c288b',
    storageBucket: 'efoot-arena-c288b.firebasestorage.app',
  );

  // iOS — à compléter quand tu ajouteras une app iOS
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC4ktDvNXONFg5sHEC4yyG4EYnWmC42N6Q',
    appId: '1:895853704319:ios:REPLACE_ME',
    messagingSenderId: '895853704319',
    projectId: 'efoot-arena-c288b',
    storageBucket: 'efoot-arena-c288b.firebasestorage.app',
    iosBundleId: 'com.efootarena.app',
  );
}
