import 'package:equatable/equatable.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Installed app version metadata from the native bundle (iOS/Android)
class AppBuildInfo extends Equatable {
  const AppBuildInfo({
    required this.version,
    required this.buildNumber,
  });

  final String version;
  final String buildNumber;

  /// User-facing label matching App Store Connect / TestFlight format
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
