import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:daily_water_tracker/common/services/app_bootstrapper.dart';
import 'package:daily_water_tracker/common/services/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  final FirebaseAuth _auth;
  final String googleServerClientId;
  static const _facebookProviderId = 'facebook.com';
  static const _passwordProviderId = 'password';

  AuthService({
    required this.googleServerClientId,
    required FirebaseAuth auth,
  }) : _auth = auth;

  User? get currentUser => _auth.currentUser;

  bool get currentUserHasPasswordProvider {
    final user = _auth.currentUser;
    if (user == null) return false;
    return user.providerData.any(
      (info) => info.providerId == _passwordProviderId,
    );
  }

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signUpWithEmailPassword({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> sendPasswordResetEmail({required String email}) {
    return _auth.sendPasswordResetEmail(
      email: email,
      actionCodeSettings: _passwordResetActionCodeSettings(),
    );
  }

  ActionCodeSettings _passwordResetActionCodeSettings() {
    final host = flutterFlavor.isProd
        ? 'dailywatertracker-app-prod.web.app'
        : 'dailywatertracker-app-dev.web.app';

    // ActionCodeSettings.url sets continueUrl on the default Firebase handler.
    // Console Action URL controls the main link host (/__/auth/action on web.app).
    return ActionCodeSettings(
      url: 'https://$host/password-reset',
    );
  }

  Future<String> verifyPasswordResetCode(String code) {
    return _auth.verifyPasswordResetCode(code);
  }

  Future<void> confirmPasswordReset({
    required String code,
    required String newPassword,
  }) {
    return _auth.confirmPasswordReset(code: code, newPassword: newPassword);
  }

  Future<UserCredential> signInWithGoogle() async {
    // Ensure Google Sign-In has a client ID on iOS. If `GIDClientID` is missing
    // from Info.plist (or GoogleService-Info.plist is not present), the plugin
    // throws "No active configuration".
    if (Platform.isIOS || Platform.isMacOS) {
      final clientId = Firebase.app().options.iosClientId;
      if (clientId != null && clientId.isNotEmpty) {
        await GoogleSignIn.instance.initialize(clientId: clientId);
      }
    } else if (Platform.isAndroid) {
      await GoogleSignIn.instance.initialize(serverClientId: googleServerClientId);
    }

    late final GoogleSignInAccount googleUser;
    try {
      googleUser = await GoogleSignIn.instance.authenticate();
    } on GoogleSignInException catch (e, st) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw FirebaseAuthException(code: 'sign-in-cancelled');
      }
      logCaughtError('AuthService.signInWithGoogle: GoogleSignInException', e, st);
      rethrow;
    }
    final googleAuth = googleUser.authentication;

    if (googleAuth.idToken == null) {
      throw FirebaseAuthException(
        code: 'missing-google-id-token',
        message:
            'Google Sign-In did not return an ID token. Check configuration (SHA-1/SHA-256, client IDs) and try again.',
      );
    }

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    return _auth.signInWithCredential(credential);
  }

  static const _nonceChars = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
  static String _randomNonce([int length = 32]) {
    final random = Random.secure();
    return List<String>.generate(length, (_) => _nonceChars[random.nextInt(_nonceChars.length)]).join();
  }

  static String _sha256Hex(String input) => sha256.convert(input.codeUnits).toString();

  static bool _looksLikeJwt(String token) {
    // Limited Login returns a JWT (3 base64url segments separated by dots).
    final parts = token.split('.');
    return parts.length == 3 && parts[0].startsWith('eyJ');
  }

  Future<UserCredential> signInWithFacebook() async {
    // On iOS, Facebook may return a Limited Login token (JWT). Firebase validates it using the nonce:
    // - we send sha256(rawNonce) into Facebook
    // - we send rawNonce into Firebase.
    final rawNonce = Platform.isIOS ? _randomNonce() : null;
    final hashedNonce = rawNonce == null ? null : _sha256Hex(rawNonce);

    final result = await FacebookAuth.instance.login(
      permissions: const ['email'],
      loginBehavior: Platform.isIOS ? LoginBehavior.webOnly : LoginBehavior.nativeWithFallback,
      loginTracking: LoginTracking.enabled,
      nonce: hashedNonce,
    );

    if (result.status == LoginStatus.cancelled) {
      throw FirebaseAuthException(code: 'sign-in-cancelled');
    }

    if (result.status != LoginStatus.success || result.accessToken == null) {
      throw FirebaseAuthException(
        code: 'facebook-login-failed',
        message: result.message ?? 'Facebook login failed.',
      );
    }

    final tokenString = result.accessToken!.tokenString;
    final AuthCredential credential = (Platform.isIOS && _looksLikeJwt(tokenString))
        ? OAuthProvider(_facebookProviderId).credential(
            idToken: tokenString,
            rawNonce: rawNonce,
          )
        : FacebookAuthProvider.credential(tokenString);
    
    return _auth.signInWithCredential(credential);
  }

  Future<UserCredential> signInWithApple() async {
    if (!Platform.isIOS) {
      throw FirebaseAuthException(
        code: 'apple-sign-in-not-supported',
        message: 'Apple Sign-In is only available on iOS.',
      );
    }

    final rawNonce = _randomNonce();
    final hashedNonce = _sha256Hex(rawNonce);

    late final AuthorizationCredentialAppleID appleCredential;
    try {
      appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );
    } on SignInWithAppleAuthorizationException catch (e, st) {
      if (_isAppleSignInUserDismissed(e)) {
        throw FirebaseAuthException(code: 'sign-in-cancelled');
      }
      logCaughtError('AuthService.signInWithApple', e, st);
      rethrow;
    }

    final idToken = appleCredential.identityToken;
    if (idToken == null) {
      throw FirebaseAuthException(
        code: 'missing-apple-identity-token',
        message: 'Apple Sign-In did not return an identityToken.',
      );
    }

    final provider = OAuthProvider('apple.com');
    final credential = provider.credential(
      idToken: idToken,
      accessToken: appleCredential.authorizationCode,
      rawNonce: rawNonce,
    );

    return _auth.signInWithCredential(credential);
  }

  /// Reauthenticates with the current password, then sets a new one.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(code: 'no-current-user');
    }

    final email = user.email;
    if (email == null || email.isEmpty) {
      throw FirebaseAuthException(code: 'no-email');
    }

    final credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  /// Permanently deletes the Firebase Auth user. Call only after Firestore/Storage cleanup.
  Future<void> deleteCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('User must be signed in.');
    }
    await user.delete();
  }

  Future<void> signOut() async {
    final signedOut = _auth.currentUser == null
        ? Future<User?>.value()
        : _auth.authStateChanges().firstWhere((user) => user == null).timeout(
              const Duration(seconds: 2),
              onTimeout: () => null,
            );
    await _auth.signOut();
    await signedOut;
    unawaited(Future.wait<void>([
      _signOutGoogleBestEffort(),
      _signOutFacebookBestEffort(),
    ]));
  }

  static bool _isAppleSignInUserDismissed(SignInWithAppleAuthorizationException e) {
    return e.code == AuthorizationErrorCode.canceled ||
        e.code == AuthorizationErrorCode.unknown;
  }

  Future<void> _signOutGoogleBestEffort() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (e, st) {
      logCaughtWarning('AuthService._signOutGoogleBestEffort', e, st);
    }
  }

  Future<void> _signOutFacebookBestEffort() async {
    try {
      await FacebookAuth.instance.logOut();
    } catch (e, st) {
      logCaughtWarning('AuthService._signOutFacebookBestEffort', e, st);
    }
  }
}

