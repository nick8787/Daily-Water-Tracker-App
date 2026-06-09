import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:daily_water_tracker/common/services/app_bootstrapper.dart';
import 'package:daily_water_tracker/common/services/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
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

  bool _googleSignInInitialized = false;
  Future<void>? _googleSignInInitFuture;

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

    // handleCodeInApp + bundle/package ids make iOS/Android open the app on a
    // single tap from the reset email (Universal/App Links).
    return ActionCodeSettings(
      url: 'https://$host/password-reset',
      handleCodeInApp: true,
      iOSBundleId: flutterFlavor.isProd
          ? 'com.dailywatertracker.app.prod'
          : 'com.dailywatertracker.app.dev',
      androidPackageName: flutterFlavor.isProd
          ? 'com.dailywatertracker.app'
          : 'com.dailywatertracker.app.dev',
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

  /// One-time Google Sign-In SDK setup. Safe to call multiple times.
  Future<void> ensureGoogleSignInInitialized() {
    return _googleSignInInitFuture ??= _initializeGoogleSignIn();
  }

  Future<void> _initializeGoogleSignIn() async {
    if (_googleSignInInitialized || kIsWeb) return;

    try {
      if (Platform.isIOS || Platform.isMacOS) {
        final clientId = Firebase.app().options.iosClientId;
        if (clientId != null && clientId.isNotEmpty) {
          await GoogleSignIn.instance.initialize(clientId: clientId);
        }
      } else if (Platform.isAndroid) {
        // Web OAuth client ID is required for Credential Manager + Firebase Auth.
        await GoogleSignIn.instance.initialize(
          serverClientId: googleServerClientId,
        );
      }
      _googleSignInInitialized = true;
    } catch (e, st) {
      _googleSignInInitFuture = null;
      logCaughtError('AuthService._initializeGoogleSignIn', e, st);
      rethrow;
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    await ensureGoogleSignInInitialized();

    late final GoogleSignInAccount googleUser;
    try {
      googleUser = await GoogleSignIn.instance.authenticate();
    } on GoogleSignInException catch (e, st) {
      logCaughtError('AuthService.signInWithGoogle: GoogleSignInException', e, st);
      throw _mapGoogleSignInException(e);
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

    try {
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e, st) {
      logCaughtError('AuthService.signInWithGoogle: FirebaseAuthException', e, st);
      rethrow;
    }
  }

  FirebaseAuthException _mapGoogleSignInException(GoogleSignInException e) {
    switch (e.code) {
      case GoogleSignInExceptionCode.canceled:
        // On Android, Credential Manager often reports SHA/config errors as
        // "canceled" after the user picks an account — do not swallow silently.
        if (Platform.isAndroid) {
          return FirebaseAuthException(
            code: 'google-sign-in-incomplete',
            message:
                'Google sign-in did not finish. If you selected an account, verify release SHA-1/SHA-256 in Firebase and google-services.json.',
          );
        }
        return FirebaseAuthException(code: 'sign-in-cancelled');
      case GoogleSignInExceptionCode.interrupted:
        return FirebaseAuthException(
          code: 'google-sign-in-interrupted',
          message: 'Google sign-in was interrupted. Please try again.',
        );
      case GoogleSignInExceptionCode.clientConfigurationError:
      case GoogleSignInExceptionCode.providerConfigurationError:
        return FirebaseAuthException(
          code: 'missing-google-id-token',
          message: e.description ??
              'Google Sign-In is misconfigured for this build.',
        );
      case GoogleSignInExceptionCode.uiUnavailable:
        return FirebaseAuthException(
          code: 'google-sign-in-unavailable',
          message: 'Google sign-in UI is unavailable on this device.',
        );
      case GoogleSignInExceptionCode.unknownError:
        return FirebaseAuthException(
          code: 'google-sign-in-failed',
          message: e.description ?? 'Google sign-in failed.',
        );
      // ignore: no_default_cases
      default:
        return FirebaseAuthException(
          code: 'google-sign-in-failed',
          message: e.description ?? 'Google sign-in failed.',
        );
    }
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

