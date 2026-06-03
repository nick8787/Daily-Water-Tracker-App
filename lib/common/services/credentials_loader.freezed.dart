// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'credentials_loader.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Credentials {

 String get appName; String get apiBaseUrl; String get googleServerClientId;
/// Create a copy of Credentials
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CredentialsCopyWith<Credentials> get copyWith => _$CredentialsCopyWithImpl<Credentials>(this as Credentials, _$identity);

  /// Serializes this Credentials to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Credentials&&(identical(other.appName, appName) || other.appName == appName)&&(identical(other.apiBaseUrl, apiBaseUrl) || other.apiBaseUrl == apiBaseUrl)&&(identical(other.googleServerClientId, googleServerClientId) || other.googleServerClientId == googleServerClientId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,appName,apiBaseUrl,googleServerClientId);

@override
String toString() {
  return 'Credentials(appName: $appName, apiBaseUrl: $apiBaseUrl, googleServerClientId: $googleServerClientId)';
}


}

/// @nodoc
abstract mixin class $CredentialsCopyWith<$Res>  {
  factory $CredentialsCopyWith(Credentials value, $Res Function(Credentials) _then) = _$CredentialsCopyWithImpl;
@useResult
$Res call({
 String appName, String apiBaseUrl, String googleServerClientId
});




}
/// @nodoc
class _$CredentialsCopyWithImpl<$Res>
    implements $CredentialsCopyWith<$Res> {
  _$CredentialsCopyWithImpl(this._self, this._then);

  final Credentials _self;
  final $Res Function(Credentials) _then;

/// Create a copy of Credentials
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? appName = null,Object? apiBaseUrl = null,Object? googleServerClientId = null,}) {
  return _then(_self.copyWith(
appName: null == appName ? _self.appName : appName // ignore: cast_nullable_to_non_nullable
as String,apiBaseUrl: null == apiBaseUrl ? _self.apiBaseUrl : apiBaseUrl // ignore: cast_nullable_to_non_nullable
as String,googleServerClientId: null == googleServerClientId ? _self.googleServerClientId : googleServerClientId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Credentials].
extension CredentialsPatterns on Credentials {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Credentials value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Credentials() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Credentials value)  $default,){
final _that = this;
switch (_that) {
case _Credentials():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Credentials value)?  $default,){
final _that = this;
switch (_that) {
case _Credentials() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String appName,  String apiBaseUrl,  String googleServerClientId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Credentials() when $default != null:
return $default(_that.appName,_that.apiBaseUrl,_that.googleServerClientId);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String appName,  String apiBaseUrl,  String googleServerClientId)  $default,) {final _that = this;
switch (_that) {
case _Credentials():
return $default(_that.appName,_that.apiBaseUrl,_that.googleServerClientId);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String appName,  String apiBaseUrl,  String googleServerClientId)?  $default,) {final _that = this;
switch (_that) {
case _Credentials() when $default != null:
return $default(_that.appName,_that.apiBaseUrl,_that.googleServerClientId);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.none)
class _Credentials implements Credentials {
  const _Credentials({required this.appName, required this.apiBaseUrl, required this.googleServerClientId});
  factory _Credentials.fromJson(Map<String, dynamic> json) => _$CredentialsFromJson(json);

@override final  String appName;
@override final  String apiBaseUrl;
@override final  String googleServerClientId;

/// Create a copy of Credentials
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CredentialsCopyWith<_Credentials> get copyWith => __$CredentialsCopyWithImpl<_Credentials>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CredentialsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Credentials&&(identical(other.appName, appName) || other.appName == appName)&&(identical(other.apiBaseUrl, apiBaseUrl) || other.apiBaseUrl == apiBaseUrl)&&(identical(other.googleServerClientId, googleServerClientId) || other.googleServerClientId == googleServerClientId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,appName,apiBaseUrl,googleServerClientId);

@override
String toString() {
  return 'Credentials(appName: $appName, apiBaseUrl: $apiBaseUrl, googleServerClientId: $googleServerClientId)';
}


}

/// @nodoc
abstract mixin class _$CredentialsCopyWith<$Res> implements $CredentialsCopyWith<$Res> {
  factory _$CredentialsCopyWith(_Credentials value, $Res Function(_Credentials) _then) = __$CredentialsCopyWithImpl;
@override @useResult
$Res call({
 String appName, String apiBaseUrl, String googleServerClientId
});




}
/// @nodoc
class __$CredentialsCopyWithImpl<$Res>
    implements _$CredentialsCopyWith<$Res> {
  __$CredentialsCopyWithImpl(this._self, this._then);

  final _Credentials _self;
  final $Res Function(_Credentials) _then;

/// Create a copy of Credentials
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? appName = null,Object? apiBaseUrl = null,Object? googleServerClientId = null,}) {
  return _then(_Credentials(
appName: null == appName ? _self.appName : appName // ignore: cast_nullable_to_non_nullable
as String,apiBaseUrl: null == apiBaseUrl ? _self.apiBaseUrl : apiBaseUrl // ignore: cast_nullable_to_non_nullable
as String,googleServerClientId: null == googleServerClientId ? _self.googleServerClientId : googleServerClientId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
