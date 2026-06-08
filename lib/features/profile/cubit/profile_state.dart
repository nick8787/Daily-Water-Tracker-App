import 'package:daily_water_tracker/features/profile/models/profile_gender.dart';
import 'package:daily_water_tracker/firebase/models/user_model.dart';
import 'package:equatable/equatable.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  const ProfileLoaded({
    required this.profile,
    required this.isPhotoEditable,
    required this.isSaving,
    required this.isPhotoLoading,
    this.errorMessage,
  });

  static const Object _noChange = Object();

  final UserModel profile;
  final bool isPhotoEditable;
  final bool isSaving;
  final bool isPhotoLoading;
  final String? errorMessage;

  ProfileGender? get gender => ProfileGender.fromWire(profile.gender);

  @override
  List<Object?> get props => [
    profile,
    isPhotoEditable,
    isSaving,
    isPhotoLoading,
    errorMessage,
  ];

  ProfileLoaded copyWith({
    UserModel? profile,
    bool? isPhotoEditable,
    bool? isSaving,
    bool? isPhotoLoading,
    Object? errorMessage = _noChange,
  }) {
    return ProfileLoaded(
      profile: profile ?? this.profile,
      isPhotoEditable: isPhotoEditable ?? this.isPhotoEditable,
      isSaving: isSaving ?? this.isSaving,
      isPhotoLoading: isPhotoLoading ?? this.isPhotoLoading,
      errorMessage: identical(errorMessage, _noChange)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}
