import 'dart:io';

import 'package:daily_water_tracker/common/widgets/profile_photo_actions_sheet.dart';
import 'package:daily_water_tracker/features/theme/app_theme_extensions.dart';
import 'package:daily_water_tracker/features/theme/theme_colors.dart';
import 'package:daily_water_tracker/features/vibration/vibration_feedback.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileAvatarCard extends StatelessWidget {
  const ProfileAvatarCard({
    super.key,
    required this.authUser,
    required this.networkPhotoUrl,
    required this.localPhotoPath,
    required this.isEditable,
    required this.showRemoveAction,
    required this.onChooseFromGallery,
    required this.onTakePhoto,
    required this.onRemovePhoto,
  });

  final User? authUser;
  final String? networkPhotoUrl;
  final String? localPhotoPath;
  final bool isEditable;
  final bool showRemoveAction;
  final VoidCallback onChooseFromGallery;
  final VoidCallback onTakePhoto;
  final VoidCallback? onRemovePhoto;

  static const double _avatarSize = 104;
  static const double _cameraSize = 34;

  bool get _hasPhoto {
    if ((localPhotoPath ?? '').trim().isNotEmpty) return true;
    return (networkPhotoUrl ?? '').trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final canInteract = isEditable;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: appCardDecoration(context),
      child: Column(
        children: [
          SizedBox(
            width: _avatarSize,
            height: _avatarSize,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: canInteract
                          ? () => _showAvatarActions(context)
                          : null,
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: AppPalette.avatarGradientColors,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(3),
                          child: ClipOval(
                            child: ColoredBox(
                              color: context.appColors.cardSurface,
                              child: _hasPhoto
                                  ? _AvatarImage(
                                      localPhotoPath: localPhotoPath,
                                      networkPhotoUrl: networkPhotoUrl,
                                    )
                                  : const _AvatarPlaceholder(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (isEditable)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Material(
                      color: context.appColors.cardSurface,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: canInteract
                            ? () => VibrationFeedback.run(
                                context,
                                () => _showAvatarActions(context),
                              )
                            : null,
                        child: Container(
                          width: _cameraSize,
                          height: _cameraSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppPalette.blackShade.withValues(alpha: 0.08),
                            ),
                          ),
                          child: const Icon(
                            Icons.photo_camera_outlined,
                            size: 18,
                            color: brandBlue,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            (authUser?.displayName ?? '').trim().isEmpty
                ? LocaleKeys.profile_avatar_fallback.tr()
                : authUser!.displayName!,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            (authUser?.email ?? '').trim().isEmpty ? '-' : authUser!.email!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  void _showAvatarActions(BuildContext context) {
    showProfilePhotoActionsSheet(
      context,
      hasPhoto: _hasPhoto,
      onChooseFromGallery: onChooseFromGallery,
      onTakePhoto: onTakePhoto,
      onRemovePhoto: showRemoveAction ? onRemovePhoto : null,
    );
  }
}

class _AvatarImage extends StatelessWidget {
  const _AvatarImage({
    required this.localPhotoPath,
    required this.networkPhotoUrl,
  });

  final String? localPhotoPath;
  final String? networkPhotoUrl;

  @override
  Widget build(BuildContext context) {
    final local = (localPhotoPath ?? '').trim();
    if (local.isNotEmpty) {
      return Image.file(
        File(local),
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, _, _) => const _AvatarPlaceholder(),
      );
    }

    final network = (networkPhotoUrl ?? '').trim();
    return Image.network(
      network,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.high,
      errorBuilder: (_, _, _) => const _AvatarPlaceholder(),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.appColors.avatarPlaceholderBg,
      child: Icon(
        Icons.person_rounded,
        size: 42,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35),
      ),
    );
  }
}
