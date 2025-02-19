// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        return windows;
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
    apiKey: 'AIzaSyAI8pw_Lia0V0hihEYanaB3MCa51ZYhF9Y',
    appId: '1:495947520541:web:736c14437c38b80b0a84f4',
    messagingSenderId: '495947520541',
    projectId: 'kyouhuku',
    authDomain: 'kyouhuku.firebaseapp.com',
    storageBucket: 'kyouhuku.appspot.com',
    measurementId: 'G-KSYBJ2MJW9',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDEqu44ZHXVCPyjT83RBTq8A-csZ2wSsqc',
    appId: '1:495947520541:android:8d381007c8f5baea0a84f4',
    messagingSenderId: '495947520541',
    projectId: 'kyouhuku',
    storageBucket: 'kyouhuku.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAS67ni2P_TGQFsdY7q9a8n6aTy8dyIkB8',
    appId: '1:495947520541:ios:101d148313b0cd4a0a84f4',
    messagingSenderId: '495947520541',
    projectId: 'kyouhuku',
    storageBucket: 'kyouhuku.appspot.com',
    iosBundleId: 'com.example.kyouhuku',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAS67ni2P_TGQFsdY7q9a8n6aTy8dyIkB8',
    appId: '1:495947520541:ios:101d148313b0cd4a0a84f4',
    messagingSenderId: '495947520541',
    projectId: 'kyouhuku',
    storageBucket: 'kyouhuku.appspot.com',
    iosBundleId: 'com.example.kyouhuku',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAI8pw_Lia0V0hihEYanaB3MCa51ZYhF9Y',
    appId: '1:495947520541:web:af9d30eaaffe73760a84f4',
    messagingSenderId: '495947520541',
    projectId: 'kyouhuku',
    authDomain: 'kyouhuku.firebaseapp.com',
    storageBucket: 'kyouhuku.appspot.com',
    measurementId: 'G-G147FC9DN9',
  );
}
