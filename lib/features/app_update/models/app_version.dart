import 'package:equatable/equatable.dart';
import 'package:pub_semver/pub_semver.dart';

class AppVersions extends Equatable {
  final Version? minIosVersion;
  final Version? minAndroidVersion;

  const AppVersions({
    required this.minIosVersion,
    required this.minAndroidVersion,
  });

  factory AppVersions.fromJson(Map<String, dynamic> json) {
    return AppVersions(
      minIosVersion: json['min_ios_version'] != null
          ? Version.parse(json['min_ios_version'])
          : null,
      minAndroidVersion: json['min_android_version'] != null
          ? Version.parse(json['min_android_version'])
          : null,
    );
  }

  @override
  List<Object?> get props => [
    minIosVersion,
    minAndroidVersion,
  ];
}
