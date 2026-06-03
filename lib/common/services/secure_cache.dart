import 'package:flutter_secure_storage/flutter_secure_storage.dart';

mixin SecureStorageMixin {
  static const String _authTokenKey = '_auth_token_key';
  static const String _refreshTokenKey = '_refresh_token_key';
  static const String _stayLoggedInKey = '_stay_logged_in_key';

  static const _storage = FlutterSecureStorage();

  Future<String?> _read(String key) async {
    return await _storage.read(key: key);
  }

  Future<Map<String, String>> readAll() async {
    return await _storage.readAll();
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  Future<void> _write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Use this method to securely save auth token
  Future<void> writeAuthToken(String value) async {
    await _write(_authTokenKey, value);
  }

  Future<String?> readAuthToken() async {
    return await _read(_authTokenKey);
  }

  Future<void> writeRefreshToken(String value) async {
    await _write(_refreshTokenKey, value);
  }

  Future<String> readRefreshToken() async {
    return await _read(_refreshTokenKey) ?? '';
  }

  Future<void> writeStayLoggedKey(String value) async {
    await _write(_stayLoggedInKey, value);
  }

  Future<void> deleteStayLoggedKey() async {
    await delete(_stayLoggedInKey);
  }

  Future<void> deleteTokens() async {
    Future.wait([
      delete(_authTokenKey),
      delete(_refreshTokenKey),
      deleteStayLoggedKey(),
    ]);
  }

  Future<bool> isStayLogged() async {
    return (await _read(_stayLoggedInKey)) == 'true';
  }
}
