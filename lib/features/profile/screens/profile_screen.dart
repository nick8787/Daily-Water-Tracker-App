import 'dart:async';

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daily_water_tracker/common/di/injector_module.dart';
import 'package:daily_water_tracker/common/router.dart';
import 'package:daily_water_tracker/common/widgets/app_loader.dart';
import 'package:daily_water_tracker/common/widgets/dismiss_keyboard_on_tap.dart';
import 'package:daily_water_tracker/common/widgets/app_primary_button.dart';
import 'package:daily_water_tracker/common/widgets/app_screen_title.dart';
import 'package:daily_water_tracker/common/widgets/app_snackbar.dart';
import 'package:daily_water_tracker/features/profile/cubit/profile_cubit.dart';
import 'package:daily_water_tracker/features/profile/cubit/profile_state.dart';
import 'package:daily_water_tracker/features/profile/models/profile_gender.dart';
import 'package:daily_water_tracker/features/profile/utils/profile_screen_helpers.dart';
import 'package:daily_water_tracker/features/profile/widgets/profile_avatar_card.dart';
import 'package:daily_water_tracker/features/profile/widgets/profile_personal_details_section.dart';
import 'package:daily_water_tracker/features/profile/widgets/profile_physical_section.dart';
import 'package:daily_water_tracker/features/profile/widgets/profile_section_card.dart';
import 'package:daily_water_tracker/features/profile/widgets/profile_stat_tiles.dart';
import 'package:daily_water_tracker/firebase/services/auth_service.dart';
import 'package:daily_water_tracker/data/repositories/firestore_repository.dart';
import 'package:daily_water_tracker/data/repositories/storage_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _fullName = TextEditingController();
  final _weight = TextEditingController();
  final _email = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _fullNameFocus = FocusNode();
  final _weightFocus = FocusNode();

  ProfileGender? _gender;
  bool _didSeedControllers = false;
  bool _wasSaving = false;
  bool _autoValidate = false;

  @override
  void dispose() {
    _fullName.dispose();
    _weight.dispose();
    _email.dispose();
    _fullNameFocus.dispose();
    _weightFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileCubit(
        authService: InjectorModule.locator<AuthService>(),
        firestoreRepository: context.read<FirestoreRepository>(),
        storageRepository: context.read<StorageRepository>(),
      )..initialize(),
      child: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) =>
            unawaited(_onProfileState(context, state)),
        builder: (context, state) {
          final loaded = state is ProfileLoaded ? state : null;
          final authUser = InjectorModule.locator<AuthService>().currentUser;
          final isFormValid = _isFormValid();

          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              scrolledUnderElevation: 0,
              surfaceTintColor: Colors.transparent,
              shadowColor: Colors.transparent,
              centerTitle: true,
              title: Text(
                LocaleKeys.profile_title.tr(),
                style: AppScreenTitle.headerStyle(context),
              ),
            ),
            body: SafeArea(
              child: DismissKeyboardOnTap(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                    children: [
                      if (loaded == null) ...[
                        const SizedBox(height: 40),
                        const Center(child: CircularProgressIndicator()),
                      ] else ...[
                        ProfileAvatarCard(
                          authUser: authUser,
                          photoUrl: profileAvatarUrl(
                            authUser: authUser,
                            profileUrl: loaded.profile.photoUrl,
                          ),
                          isEditable: loaded.isPhotoEditable,
                          isLoading: loaded.isPhotoLoading,
                          onPickPhoto: loaded.isPhotoEditable
                              ? () => context
                                    .read<ProfileCubit>()
                                    .pickAndUploadPhoto()
                              : null,
                        ),
                        const SizedBox(height: 16),
                        ProfilePersonalDetailsSection(
                          formKey: _formKey,
                          autovalidateMode: _nameFieldsNeedAttention()
                              ? AutovalidateMode.always
                              : (_autoValidate
                                    ? AutovalidateMode.onUserInteraction
                                    : AutovalidateMode.disabled),
                          fullName: _fullName,
                          email: _email,
                          fullNameFocus: _fullNameFocus,
                          onFullNameChanged: () => setState(() {}),
                          onFullNameSubmitted: (_) =>
                              _weightFocus.requestFocus(),
                        ),
                        const SizedBox(height: 14),
                        ProfilePhysicalSection(
                          weightController: _weight,
                          weightFocus: _weightFocus,
                          gender: _gender,
                          onWeightChanged: () => setState(() {}),
                          onGenderChanged: (v) => setState(() => _gender = v),
                        ),
                        const SizedBox(height: 14),
                        ProfileSectionCard(
                          title: LocaleKeys.profile_section_stats.tr(),
                          child: ProfileStatTiles(
                            memberSince: profileMemberSince(authUser),
                            totalDays: profileTotalDays(authUser).toString(),
                          ),
                        ),
                        const SizedBox(height: 18),
                        AppGradientButton(
                          label: LocaleKeys.profile_button_save.tr(),
                          enabled: !loaded.isSaving && isFormValid,
                          busy: loaded.isSaving,
                          onTap: () => _onSavePressed(context),
                        ),
                      ],
                    ],
                  ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _onProfileState(BuildContext context, ProfileState state) async {
    if (state is! ProfileLoaded) return;

    final justFinishedSaving = _wasSaving && !state.isSaving;
    _wasSaving = state.isSaving;

    if (state.isSaving) {
      AppLoader.show(context, message: LocaleKeys.loader_saving.tr());
    } else if (AppLoader.isShowing) {
      await AppLoader.hideWithMinimumVisibleDuration();
    }
    if (!context.mounted) return;

    if (state.errorMessage != null) {
      AppSnackBar.showError(context, state.errorMessage!.tr());
    }
    if (justFinishedSaving && state.errorMessage == null && context.mounted) {
      Navigator.of(context).pop();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final snackContext = rootNavigatorKey.currentContext;
        if (snackContext == null) return;
        AppSnackBar.showSuccess(
          snackContext,
          title: LocaleKeys.profile_snackbar_saved_title.tr(),
          message: LocaleKeys.profile_snackbar_saved_message.tr(),
          dismissAfter: const Duration(seconds: 3),
        );
      });
    }

    if (!_didSeedControllers) {
      final authUser = InjectorModule.locator<AuthService>().currentUser;
      _fullName.text = seedProfileFullName(
        firstName: state.profile.firstName,
        lastName: state.profile.lastName,
        userName: state.profile.userName,
        authDisplayName: authUser?.displayName,
      );
      final w = state.profile.weightKg;
      _weight.text = w == null ? '' : w.toString();
      _email.text = state.profile.email.trim();
      _gender = ProfileGender.fromWire(state.profile.gender);
      _didSeedControllers = true;
    }
  }

  void _onSavePressed(BuildContext context) {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      setState(() => _autoValidate = true);
      return;
    }

    final weightText = _weight.text.trim();
    final clearWeight = weightText.isEmpty;
    final weight = clearWeight ? null : int.tryParse(weightText);
    context.read<ProfileCubit>().saveProfile(
      fullName: _fullName.text,
      weightKg: weight,
      clearWeightKg: clearWeight,
      gender: _gender,
    );
  }

  bool _nameFieldsNeedAttention() {
    if (!_didSeedControllers) return false;
    return _fullName.text.trim().isEmpty;
  }

  bool _isFormValid() {
    if (_fullName.text.trim().isEmpty) return false;

    final w = _weight.text.trim();
    if (w.isNotEmpty) {
      final parsed = int.tryParse(w);
      if (parsed == null) return false;
      if (parsed <= 0 || parsed > 600) return false;
    }
    return true;
  }
}
