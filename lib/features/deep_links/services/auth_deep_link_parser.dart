import 'package:daily_water_tracker/features/deep_links/models/auth_password_reset_link.dart';

/// Builds a go_router location for [CompletePasswordResetScreen] when [uri]
/// contains a password-reset action code.
String? passwordResetRedirectLocation(
  Uri uri, {
  String completePasswordResetRoute = '/login/complete-password-reset',
}) {
  final link = parseAuthPasswordResetLink(uri);
  if (link == null) return null;

  return '$completePasswordResetRoute'
      '?oobCode=${Uri.encodeComponent(link.oobCode)}';
}

AuthPasswordResetLink? parseAuthPasswordResetLink(Uri uri) {
  final candidates = _expandLinkCandidates(uri);
  for (final candidate in candidates) {
    final parsed = _parseDirectPasswordReset(candidate);
    if (parsed != null) return parsed;
  }
  return null;
}

List<Uri> _expandLinkCandidates(Uri uri) {
  final seen = <String>{};
  final pending = <Uri>[uri];
  final expanded = <Uri>[];

  while (pending.isNotEmpty) {
    final current = pending.removeAt(0);
    final key = current.toString();
    if (!seen.add(key)) continue;

    expanded.add(current);

    for (final nested in _nestedLinkUris(current)) {
      if (!seen.contains(nested.toString())) {
        pending.add(nested);
      }
    }
  }

  return expanded;
}

Iterable<Uri> _nestedLinkUris(Uri uri) sync* {
  for (final entry in uri.queryParameters.entries) {
    if (!_isNestedLinkKey(entry.key)) continue;

    final raw = entry.value.trim();
    if (raw.isEmpty) continue;

    final nested = Uri.tryParse(raw);
    if (nested != null) {
      yield nested;
      continue;
    }

    final decoded = Uri.tryParse(Uri.decodeComponent(raw));
    if (decoded != null) yield decoded;
  }
}

bool _isNestedLinkKey(String key) {
  return key == 'link' || key == 'deep_link_id' || key == 'continueUrl';
}

AuthPasswordResetLink? _parseDirectPasswordReset(Uri uri) {
  if (!_isSupportedHost(uri.host)) return null;

  final path = _normalizedPath(uri.path);
  if (!_isPasswordResetPath(path)) return null;

  final oobCode = (uri.queryParameters['oobCode'] ?? '').trim();
  if (oobCode.isEmpty) return null;

  final mode = uri.queryParameters['mode'];
  if (mode != null && mode != 'resetPassword') return null;

  return AuthPasswordResetLink(oobCode: oobCode);
}

bool _isPasswordResetPath(String path) {
  if (path == '/password-reset' || path.startsWith('/password-reset/')) {
    return true;
  }
  if (path == '/__/auth/action' ||
      path == '/__/auth/links' ||
      path.startsWith('/__/auth/')) {
    return true;
  }
  return false;
}

bool _isSupportedHost(String host) {
  return _devHosts.contains(host) || _prodHosts.contains(host);
}

const _devHosts = {
  'dailywatertracker-app-dev.web.app',
  'dailywatertracker-app-dev.firebaseapp.com',
};

const _prodHosts = {
  'dailywatertracker-app-prod.web.app',
  'dailywatertracker-app-prod.firebaseapp.com',
};

String _normalizedPath(String path) {
  if (path.endsWith('/') && path.length > 1) {
    return path.substring(0, path.length - 1);
  }
  return path;
}
