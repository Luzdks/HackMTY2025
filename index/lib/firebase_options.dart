import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web.',
      );
    }
    // Por ahora, solo nos importa Android
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // --- ¡¡¡AQUÍ VA TU INFORMACIÓN!!! ---
  // Copia y pega los valores de tu 'google-services.json'
  
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAsE61kcRPeDYBkUjqzRKwH89ulcXpDuSQ', // <-- Pega el "current_key" aquí
    appId: '1:914749932353:android:1f6efb443df2f8f22dd7c0', // <-- Pega el "mobilesdk_app_id" aquí
    messagingSenderId: '914749932353', // <-- Pega el "project_number" aquí
    projectId: 'capitalone-c4bfe', // <-- Pega el "project_id" aquí
    storageBucket: 'capitalone-c4bfe.firebasestorage.app', // <-- Pega el "storage_bucket" aquí
  );
}