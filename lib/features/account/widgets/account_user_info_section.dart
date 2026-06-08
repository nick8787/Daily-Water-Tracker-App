import 'package:daily_water_tracker/common/di/injector_module.dart';
import 'package:daily_water_tracker/data/repositories/firestore_repository.dart';
import 'package:daily_water_tracker/features/account/cubit/account_cubit.dart';
import 'package:daily_water_tracker/features/account/cubit/account_state.dart';
import 'package:daily_water_tracker/features/account/widgets/account_profile_header.dart';
import 'package:daily_water_tracker/features/account/widgets/account_user_display.dart';
import 'package:daily_water_tracker/firebase/services/auth_service.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class AccountUserInfoSection extends StatelessWidget {
  const AccountUserInfoSection({
    super.key,
    required this.signingOut,
    required this.logoutFreeze,
  });

  final bool signingOut;
  final AccountLogoutUiFreeze? logoutFreeze;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: context.read<FirestoreRepository>().watchUserProfile(),
      builder: (context, snapshot) {
        final freeze = logoutFreeze;
        if (signingOut && freeze != null) {
          return _FrozenProfileHeader(freeze: freeze);
        }

        final authService = InjectorModule.locator<AuthService>();
        final authUser = authService.currentUser;
        if (authUser == null) {
          return const SizedBox.shrink();
        }
        final profile = snapshot.data;

        final email = (profile?.email ?? authUser.email ?? '').trim();
        final displayName =
            (profile?.userName ?? accountDisplayNameFromUser(authUser)).trim();
        final avatarUrl = ((profile?.photoUrl ?? authUser.photoURL) ?? '')
            .trim();
        final hasAnyPhoto = avatarUrl.isNotEmpty;
        final hasCustomPhoto = (profile?.photoId ?? '').trim().isNotEmpty;
        final isEditable = !hasAnyPhoto || hasCustomPhoto;

        return Builder(
          builder: (context) {
            final isPhotoLoading = context
                .select<AccountCubit, bool>((c) => c.state.isPhotoBusy);
            return AccountProfileHeader(
              displayName: displayName.isEmpty ? LocaleKeys.common_user_default.tr() : displayName,
              email: email.isEmpty ? '-' : email,
              photoUrl: avatarUrl.isEmpty ? null : avatarUrl,
              isPhotoLoading: isPhotoLoading,
              isEditable: isEditable,
              onChooseFromGallery: () {
                context.read<AccountCubit>().pickAndUploadPhoto(
                  source: ImageSource.gallery,
                );
              },
              onTakePhoto: () {
                context.read<AccountCubit>().pickAndUploadPhoto(
                  source: ImageSource.camera,
                );
              },
              onRemovePhoto: hasCustomPhoto
                  ? () => context.read<AccountCubit>().removePhoto()
                  : null,
            );
          },
        );
      },
    );
  }
}

class _FrozenProfileHeader extends StatelessWidget {
  const _FrozenProfileHeader({required this.freeze});

  final AccountLogoutUiFreeze freeze;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AccountProfileHeader(
        displayName: freeze.displayName.isEmpty ? LocaleKeys.common_user_default.tr() : freeze.displayName,
        email: freeze.email.isEmpty ? '-' : freeze.email,
        photoUrl: freeze.photoUrl,
        isPhotoLoading: false,
        isEditable: freeze.isEditable,
        onChooseFromGallery: () {},
        onTakePhoto: () {},
        onRemovePhoto: freeze.hasCustomPhoto ? () {} : null,
      ),
    );
  }
}
