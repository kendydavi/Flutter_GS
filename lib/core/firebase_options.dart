import 'package:firebase_core/firebase_core.dart';
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
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions nao foi configurado para esta plataforma.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
      apiKey: "AIzaSyDhfNBpZsCsFRdq72CtQN_oR4PeBvx835o",
      authDomain: "fir-app-6df9b.firebaseapp.com",
      projectId: "fir-app-6df9b",
      storageBucket: "fir-app-6df9b.firebasestorage.app",
      messagingSenderId: "439504174307",
      appId: "1:439504174307:web:4eb0e561055c908beb99d6",
      measurementId: "G-0KYF5SWM3Y",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'ANDROID_API_KEY',
    appId: 'ANDROID_APP_ID',
    messagingSenderId: 'MESSAGING_SENDER_ID',
    projectId: 'PROJECT_ID',
    storageBucket: 'PROJECT_ID.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: "",
    authDomain: "",
    projectId: "",
    storageBucket: "",
    messagingSenderId: "",
    appId: "",
    measurementId: "",
  );
}
