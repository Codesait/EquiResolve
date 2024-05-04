// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyAk0OJuEUSCucvT1aXn9azo-Reio_g9d6w',
    appId: '1:19738508514:web:8f552181d6bd814841b2bb',
    messagingSenderId: '19738508514',
    projectId: 'equiresolveapp',
    authDomain: 'equiresolveapp.firebaseapp.com',
    databaseURL: 'https://equiresolveapp-default-rtdb.firebaseio.com',
    storageBucket: 'equiresolveapp.appspot.com',
    measurementId: 'G-7J8YQHRDTK',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDTBRvDblhjXi8nlN9gWB5MAFsBGQ3Y4FU',
    appId: '1:19738508514:ios:a0e7eeb5ad595dfa41b2bb',
    messagingSenderId: '19738508514',
    projectId: 'equiresolveapp',
    databaseURL: 'https://equiresolveapp-default-rtdb.firebaseio.com',
    storageBucket: 'equiresolveapp.appspot.com',
    androidClientId: '19738508514-td2o8n39cnvqau9curmq23tt8g9b49h8.apps.googleusercontent.com',
    iosClientId: '19738508514-cif9mkedb68f281efcn4apoeg1ckimj6.apps.googleusercontent.com',
    iosBundleId: 'com.example.equiresolve',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAzybbXqNDytu1rPbmWnE_TqImX2zud0Ug',
    appId: '1:19738508514:android:c284393c909f2c4541b2bb',
    messagingSenderId: '19738508514',
    projectId: 'equiresolveapp',
    databaseURL: 'https://equiresolveapp-default-rtdb.firebaseio.com',
    storageBucket: 'equiresolveapp.appspot.com',
  );

}