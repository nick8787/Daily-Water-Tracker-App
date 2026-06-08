import 'package:equatable/equatable.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Installed app version metadata from the native bundle (iOS/Android).
///
/// [version] and [buildNumber] are baked into the binary at build time from
/// per-flavor metadata (`versions/dev.properties`, `versions/prod.properties`,
/// `ios/config/*/Version.xcconfig`). CI refreshes those files before each build.
///
/// Each installed build always shows its own label (e.g. prod `1.0.4 (5)`,
/// dev `0.0.15 (15)`), including after version rollbacks.
class AppBuildInfo extends Equatable {
  const AppBuildInfo({
    required this.version,
    required this.buildNumber,
  });

  final String version;
  final String buildNumber;

  /// User-facing label matching App Store Connect / TestFlight format.
  String get displayLabel => '$version ($buildNumber)';

  static Future<AppBuildInfo> load() async {
    final packageInfo = await PackageInfo.fromPlatform();

    return AppBuildInfo(
      version: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
    );
  }

  @override
  List<Object?> get props => [version, buildNumber];
}
