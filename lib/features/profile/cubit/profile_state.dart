import 'package:daily_water_tracker/features/profile/models/profile_gender.dart';
import 'package:daily_water_tracker/features/profile/models/profile_photo_draft.dart';
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
    this.photoDraft = const ProfilePhotoDraftNone(),
    this.errorMessage,
  });

  static const Object _noChange = Object();

  final UserModel profile;
  final bool isPhotoEditable;
  final bool isSaving;
  final ProfilePhotoDraft photoDraft;
  final String? errorMessage;

  ProfileGender? get gender => ProfileGender.fromWire(profile.gender);

  bool get hasPendingPhotoDraft => photoDraft is! ProfilePhotoDraftNone;

  @override
  List<Object?> get props => [
    profile,
    isPhotoEditable,
    isSaving,
    photoDraft,
    errorMessage,
  ];

  ProfileLoaded copyWith({
    UserModel? profile,
    bool? isPhotoEditable,
    bool? isSaving,
    ProfilePhotoDraft? photoDraft,
    Object? errorMessage = _noChange,
    bool clearPhotoDraft = false,
  }) {
    return ProfileLoaded(
      profile: profile ?? this.profile,
      isPhotoEditable: isPhotoEditable ?? this.isPhotoEditable,
      isSaving: isSaving ?? this.isSaving,
      photoDraft: clearPhotoDraft
          ? const ProfilePhotoDraftNone()
          : (photoDraft ?? this.photoDraft),
      errorMessage: identical(errorMessage, _noChange)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}
