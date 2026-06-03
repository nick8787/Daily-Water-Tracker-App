import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../firebase/dev/firebase_options.dart' as dev_options;
import '../../firebase/prod/firebase_options.dart' as prod_options;

const _flavorKey = 'FLAVOR';

enum AppFlavor {
  dev,
  prod;

  bool get isDev => this == AppFlavor.dev;
  bool get isProd => this == AppFlavor.prod;

  static Future<AppFlavor> fromAppFlavor() async {
    const flavor = kIsWeb ? String.fromEnvironment(_flavorKey) : appFlavor;
    return _fromString(flavor);
  }

  static AppFlavor _fromString(String? flavor) {
    switch (flavor) {
      case 'dev':
        return AppFlavor.dev;
      case 'prod':
        return AppFlavor.prod;
      default:
        // Default to dev to keep local runs convenient.
        // In CI/release you should always provide the proper flavor explicitly.
        return AppFlavor.dev;
    }
  }

  FirebaseOptions get getFirebaseOptions {
    switch (this) {
      case AppFlavor.dev:
        return dev_options.DefaultFirebaseOptions.currentPlatform;
      case AppFlavor.prod:
        return prod_options.DefaultFirebaseOptions.currentPlatform;
    }
  }
}
