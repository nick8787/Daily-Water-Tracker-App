import 'package:daily_water_tracker/features/theme/app_theme_extensions.dart';
import 'package:daily_water_tracker/features/theme/theme_colors.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileAvatarCard extends StatelessWidget {
  const ProfileAvatarCard({
    super.key,
    required this.authUser,
    required this.photoUrl,
    required this.isEditable,
    required this.isLoading,
    required this.onPickPhoto,
  });

  final User? authUser;
  final String photoUrl;
  final bool isEditable;
  final bool isLoading;
  final VoidCallback? onPickPhoto;

  static const double _avatarSize = 104;
  static const double _cameraSize = 34;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl.trim().isNotEmpty;
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
                          child: Stack(
                            children: [
                              if (hasPhoto)
                                Positioned.fill(
                                  child: Image.network(
                                    photoUrl,
                                    fit: BoxFit.cover,
                                    filterQuality: FilterQuality.high,
                                    errorBuilder: (_, _, _) =>
                                        const _AvatarPlaceholder(),
                                  ),
                                )
                              else
                                const Positioned.fill(
                                  child: _AvatarPlaceholder(),
                                ),
                              if (isLoading)
                                Positioned.fill(
                                  child: ColoredBox(
                                    color: context.appColors.cardSurface.withValues(
                                      alpha: 0.62,
                                    ),
                                  ),
                                ),
                            ],
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
                        onTap: isLoading ? null : onPickPhoto,
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
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
