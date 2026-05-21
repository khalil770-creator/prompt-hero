// IMPORTANT: This file is a placeholder.
// Replace the entire contents of this file with the output from the FlutterFire CLI:
//
//   flutter pub global activate flutterfire_cli
//   flutterfire configure
//
// The flutterfire configure command will generate the correct DefaultFirebaseOptions
// for all your target platforms (Web, Android, iOS, macOS, Windows).
//
// Do NOT commit your actual firebase_options.dart to public repositories as it
// contains API keys. Add it to .gitignore if your repo is public.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Replace this with the output of `flutterfire configure`.
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
    apiKey: 'AIzaSyCGQ_MF5xyzQIjI8PrskdyxqrCrRmzNgyU',
    appId: '1:402660089849:web:21520fec4caa8dadd7e728',
    messagingSenderId: '402660089849',
    projectId: 'prompthero-de0f4',
    authDomain: 'prompthero-de0f4.firebaseapp.com',
    databaseURL: 'https://prompthero-de0f4-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'prompthero-de0f4.firebasestorage.app',
    measurementId: 'G-FLCE49TEC8',
  );

  // PLACEHOLDER — replace with your actual config

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCvoU9tQipBcELHQUX1ro8V2POclvD0B6Q',
    appId: '1:402660089849:android:e3fd35402cafb0a2d7e728',
    messagingSenderId: '402660089849',
    projectId: 'prompthero-de0f4',
    databaseURL: 'https://prompthero-de0f4-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'prompthero-de0f4.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCzNF6CmtmekZW2TCtEtsrVpwqmL_kv_no',
    appId: '1:402660089849:ios:baa4ae686bc68689d7e728',
    messagingSenderId: '402660089849',
    projectId: 'prompthero-de0f4',
    databaseURL: 'https://prompthero-de0f4-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'prompthero-de0f4.firebasestorage.app',
    iosBundleId: 'com.promptvault.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_MACOS_API_KEY',
    appId: 'YOUR_MACOS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    iosBundleId: 'com.example.promptVault',
  );
}