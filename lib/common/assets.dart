import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

const String credentialsDevFile = 'assets/config_development.json';
const String credentialsProdFile = 'assets/config_production.json';
const String translationsFolderPath = 'assets/i18n';

const _images = 'assets/images';
const _svgs = 'assets/svgs';

const String splashLaunchBackground =
    'assets/splash/ios/launch_background_full.png';
const String splashWordmark = 'assets/splash/wordmark_full.png';

const String icMap = '$_images/ic_map.png';

const String menuIc = '$_svgs/menu.svg';
const String icInfoSvg = '$_svgs/info.svg';

const String appleMark = '$_images/apple_mark.png';
const String googleMark = '$_images/google_mark.png';
const String facebookMark = '$_images/facebook_mark.png';

const String icAccountBlack = '$_images/ic_account_black.png';
const String glassOfWater = '$_images/glass_of_water.png';

const String icUserProfile = '$_images/ic_user_profile.png';
const String icUserPreferences = '$_images/ic_user_preferences.png';
const String icUserHistory = '$_images/ic_user_history.png';
const String icShareMyProgress = '$_images/ic_share_my_progress.png';
const String icProfileSecurity = '$_images/ic_profile_security.png';
const String icPrivacyPolicy = '$_images/ic_privacy_policy.png';
const String icAccountLogOut = '$_images/ic_account_log_out.png';
const String icDeleteAccountRed = '$_images/ic_delete_account_red.png';
const String icAccountNotifications = '$_images/ic_account_notification.png';

Future<void> precacheImages(BuildContext context) async {
  Future.wait([
    precacheImage(const AssetImage(icMap), context),
    precacheImage(const AssetImage(splashLaunchBackground), context),
    precacheImage(const AssetImage(splashWordmark), context),
  ]);
}

Future<void> precacheSvgs() async {
  final assetManifest = await AssetManifest.loadFromAssetBundle(rootBundle);
  final assets = assetManifest.listAssets();
  final svgsPaths = assets.where(
    (path) => path.startsWith(_svgs) && path.endsWith('.svg'),
  );

  for (final svgPath in svgsPaths) {
    final loader = SvgAssetLoader(svgPath);
    await svg.cache.putIfAbsent(
      loader.cacheKey(null),
      () => loader.loadBytes(null),
    );
  }
}
