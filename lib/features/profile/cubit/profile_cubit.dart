import 'dart:async';
import 'dart:io';

import 'package:daily_water_tracker/common/utils/crashlytics.dart';
import 'package:daily_water_tracker/data/repositories/firestore_repository.dart';
import 'package:daily_water_tracker/data/repositories/storage_repository.dart';
import 'package:daily_water_tracker/features/profile/models/profile_gender.dart';
import 'package:daily_water_tracker/firebase/models/user_model.dart';
import 'package:daily_water_tracker/firebase/services/auth_service.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required AuthService authService,
    required FirestoreRepository firestoreRepository,
    required StorageRepository storageRepository,
    ImagePicker? imagePicker,
  }) : _authService = authService,
       _firestoreRepository = firestoreRepository,
       _storageRepository = storageRepository,
       _imagePicker = imagePicker ?? ImagePicker(),
       super(const ProfileLoading());

  final AuthService _authService;
  final FirestoreRepository _firestoreRepository;
  final StorageRepository _storageRepository;
  final ImagePicker _imagePicker;

  StreamSubscription<UserModel?>? _profileSub;

  User? get _authUser => _authService.currentUser;

  Future<void> initialize() async {
    await _profileSub?.cancel();
    _profileSub = _firestoreRepository.watchUserProfile().listen((profile) {
      final authUser = _authUser;
      if (authUser == null || profile == null) return;

      final authPhotoUrl = (authUser.photoURL ?? '').trim();
      final profilePhotoId = (profile.photoId ?? '').trim();
      final profilePhotoUrl = (profile.photoUrl ?? '').trim();
      final hasAnyPhoto = authPhotoUrl.isNotEmpty || profilePhotoUrl.isNotEmpty;
      final hasCustomPhoto = profilePhotoId.isNotEmpty;
      final isEditable = !hasAnyPhoto || hasCustomPhoto;

      final prev = state;
      if (prev is ProfileLoaded) {
        emit(
          prev.copyWith(
            profile: profile,
            isPhotoEditable: isEditable,
            errorMessage: null,
          ),
        );
      } else {
        emit(
          ProfileLoaded(
            profile: profile,
            isPhotoEditable: isEditable,
            isSaving: false,
            isPhotoLoading: false,
          ),
        );
      }
    });
  }

  Future<void> saveProfile({
    required String fullName,
    required int? weightKg,
    required bool clearWeightKg,
    required ProfileGender? gender,
  }) async {
    final current = state;
    if (current is! ProfileLoaded) return;
    final user = _authUser;
    if (user == null) return;

    emit(current.copyWith(isSaving: true, errorMessage: null));
    try {
      final name = fullName.trim();

      await _firestoreRepository.updateUserProfile(
        userName: name.isEmpty ? null : name,
        clearFirstName: true,
        clearLastName: true,
        weightKg: weightKg,
        clearWeightKg: clearWeightKg,
        isAutoGoalEnabled: clearWeightKg ? false : null,
        gender: gender?.wire,
      );

      emit(current.copyWith(isSaving: false));
    } catch (e, st) {
      await recordCrashlyticsError(
        e,
        StackTrace.current,
        st,
        reason: 'ProfileCubit.saveProfile',
      );
      emit(
        current.copyWith(
          isSaving: false,
          errorMessage: LocaleKeys.profile_error_save_failed,
        ),
      );
    }
  }

  Future<void> pickAndUploadPhoto() async {
    final current = state;
    if (current is! ProfileLoaded) return;
    final user = _authUser;
    if (user == null) return;

    emit(current.copyWith(isPhotoLoading: true, errorMessage: null));
    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      if (picked == null) {
        emit(current.copyWith(isPhotoLoading: false));
        return;
      }

      final upload = await _storageRepository.uploadProfilePhoto(
        uid: user.uid,
        file: File(picked.path),
      );
      await _firestoreRepository.updateUserProfile(
        photoId: upload.objectPath,
        photoUrl: upload.downloadUrl,
      );
      emit(current.copyWith(isPhotoLoading: false));
    } catch (e, st) {
      await recordCrashlyticsError(
        e,
        StackTrace.current,
        st,
        reason: 'ProfileCubit.pickAndUploadPhoto',
      );
      emit(
        current.copyWith(
          isPhotoLoading: false,
          errorMessage: LocaleKeys.profile_error_upload_photo,
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _profileSub?.cancel();
    return super.close();
  }
}
