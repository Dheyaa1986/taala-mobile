import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Firebase is not configured for web.');
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'Firebase is not configured for $defaultTargetPlatform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBHp0t4gqAUXYI8UpteRMvnKyfFI_ZA4Tk',
    appId: '1:105251793425:android:bdc84c6a2f599edbd31fb0',
    messagingSenderId: '105251793425',
    projectId: 'taal-c4eb3',
    storageBucket: 'taal-c4eb3.firebasestorage.app',
  );

  // Replace appId after adding the iOS app in Firebase Console.
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBHp0t4gqAUXYI8UpteRMvnKyfFI_ZA4Tk',
    appId: '1:105251793425:ios:REPLACE_WITH_IOS_APP_ID',
    messagingSenderId: '105251793425',
    projectId: 'taal-c4eb3',
    storageBucket: 'taal-c4eb3.firebasestorage.app',
    iosBundleId: 'com.mintops.taala',
  );
}
