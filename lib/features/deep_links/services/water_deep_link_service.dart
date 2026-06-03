import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:daily_water_tracker/common/services/app_bootstrapper.dart';

class WaterDeepLinkService {
  WaterDeepLinkService({
    AppLinks? appLinks,
  }) : _appLinks = appLinks ?? AppLinks();

  final AppLinks _appLinks;

  Stream<Uri> get uriStream => _appLinks.uriLinkStream;

  Future<Uri?> getInitialUri() => _appLinks.getInitialLink();

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
