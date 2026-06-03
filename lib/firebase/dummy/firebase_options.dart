import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

/// THIS IS DUMMY FIREBASE OPTIONS JUST FOR CODE METRICS SCRIPT TO BE WORKING.
/// IT WILL BE MOVED TO "/lib" IN `.gitlab-ci.yml` SCRIPT.

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    throw Exception();
  }
}
