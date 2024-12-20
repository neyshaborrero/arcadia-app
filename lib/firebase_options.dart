// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

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
///

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDPoih-EcEwUKVk3QKwtPk6EYOAU69rFpM',
    appId: '1:375872375930:android:c1506fb54081c17ed5ffc3',
    messagingSenderId: '375872375930',
    projectId: 'ysug-arcadia-46a15',
    databaseURL: 'https://ysug-arcadia-46a15-default-rtdb.firebaseio.com',
    storageBucket: 'ysug-arcadia-46a15.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAyD5Bn9ntE8y40MLREymEq3VP5OAfVWzY',
    appId: '1:375872375930:ios:a530f50d0b7ffe75d5ffc3',
    messagingSenderId: '375872375930',
    projectId: 'ysug-arcadia-46a15',
    databaseURL: 'https://ysug-arcadia-46a15-default-rtdb.firebaseio.com',
    storageBucket: 'ysug-arcadia-46a15.appspot.com',
    iosBundleId: 'com.ysug.arcadia',
  );

}