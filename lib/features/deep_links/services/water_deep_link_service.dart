import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:daily_water_tracker/common/services/app_bootstrapper.dart';

class WaterDeepLinkService {
  WaterDeepLinkService({
    AppLinks? appLinks,
  }) : _appLinks = appLinks ?? AppLinks();

  final AppLinks _appLinks;
  Uri? _cachedInitialUri;
  bool _initialUriCaptured = false;

  Stream<Uri> get uriStream => _appLinks.uriLinkStream;

  /// Call as early as possible on cold start (before [runApp]) so iOS does not
  /// drop the universal link that opened the app.
  Future<void> captureInitialUriEarly() async {
    if (_initialUriCaptured) return;
    _initialUriCaptured = true;

    try {
      _cachedInitialUri = await _appLinks.getInitialLink();
    } catch (_) {
      _cachedInitialUri = null;
    }
  }

  Future<Uri?> getInitialUri() async {
    if (_cachedInitialUri != null) return _cachedInitialUri;
    return _appLinks.getInitialLink();
  }

  String get shareDomain {
    if (flutterFlavor.isProd) {
      return 'dailywatertracker-app-prod.web.app';
    }
    return 'dailywatertracker-app-dev.web.app';
  }

  Uri buildShareProgressUri({required int ml}) {
    return Uri.https(
      shareDomain,
      '/share',
      <String, String>{'ml': '$ml'},
    );
  }
}
