// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credentials_loader.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Credentials _$CredentialsFromJson(Map<String, dynamic> json) => _Credentials(
  appName: json['appName'] as String,
  apiBaseUrl: json['apiBaseUrl'] as String,
  googleServerClientId: json['googleServerClientId'] as String,
);

Map<String, dynamic> _$CredentialsToJson(_Credentials instance) =>
    <String, dynamic>{
      'appName': instance.appName,
      'apiBaseUrl': instance.apiBaseUrl,
      'googleServerClientId': instance.googleServerClientId,
    };
