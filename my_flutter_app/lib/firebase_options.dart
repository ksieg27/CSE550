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
    apiKey: 'AIzaSyBGrE6je1ScYpmdHDFZcTp5onXKYcs_2lk',
    appId: '1:685357833510:web:c604d101676eaf8c15b5e7',
    messagingSenderId: '685357833510',
    projectId: 'cse550-medreminder-app',
    authDomain: 'cse550-medreminder-app.firebaseapp.com',
    storageBucket: 'cse550-medreminder-app.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBcy2efVhtpe3i0RTiqzGTiwVCl_dEDWz0',
    appId: '1:685357833510:android:e58079d74905569715b5e7',
    messagingSenderId: '685357833510',
    projectId: 'cse550-medreminder-app',
    storageBucket: 'cse550-medreminder-app.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCLoJ6NGo18XdxNpjNY65nc92KtfSVVxr4',
    appId: '1:685357833510:ios:f4ef76f53f69350e15b5e7',
    messagingSenderId: '685357833510',
    projectId: 'cse550-medreminder-app',
    storageBucket: 'cse550-medreminder-app.firebasestorage.app',
    iosBundleId: 'com.example.myFlutterApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCLoJ6NGo18XdxNpjNY65nc92KtfSVVxr4',
    appId: '1:685357833510:ios:f4ef76f53f69350e15b5e7',
    messagingSenderId: '685357833510',
    projectId: 'cse550-medreminder-app',
    storageBucket: 'cse550-medreminder-app.firebasestorage.app',
    iosBundleId: 'com.example.myFlutterApp',
  );

}