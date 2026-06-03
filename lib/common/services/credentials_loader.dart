import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'logger.dart';

part 'credentials_loader.freezed.dart';
part 'credentials_loader.g.dart';

class CredentialsLoader {
  final String pathToFile;

  CredentialsLoader({required this.pathToFile});

  Future<Credentials> load() {
    return rootBundle.loadStructuredData<Credentials>(pathToFile, (
      jsonStr,
    ) async {
      final secret = Credentials.fromJson(json.decode(jsonStr));
      log.fine('secret $secret');
      return secret;
    });
  }
}

@freezed
abstract class Credentials with _$Credentials {
  // ignore: invalid_annotation_target
  @JsonSerializable(fieldRename: FieldRename.none)
  const factory Credentials({
    required String appName,
    required String apiBaseUrl,
    required String googleServerClientId,
  }) = _Credentials;

  factory Credentials.fromJson(Map<String, dynamic> json) =>
      _$CredentialsFromJson(json);
}
