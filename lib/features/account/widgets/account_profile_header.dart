import 'package:daily_water_tracker/common/widgets/profile_photo_actions_sheet.dart';
import 'package:daily_water_tracker/features/theme/app_theme_extensions.dart';
import 'package:daily_water_tracker/features/theme/shadow.dart';
import 'package:daily_water_tracker/features/theme/theme_colors.dart';
import 'package:flutter/material.dart';

class AccountProfileHeader extends StatelessWidget {
  const AccountProfileHeader({
    super.key,
    required this.displayName,
    required this.email,
    required this.photoUrl,
    required this.isPhotoLoading,
    required this.isEditable,
    required this.onChooseFromGallery,
    required this.onTakePhoto,
    required this.onRemovePhoto,
  });

  final String displayName;
  final String email;
  final String? photoUrl;
  final bool isPhotoLoading;
  final bool isEditable;

  final VoidCallback onChooseFromGallery;
  final VoidCallback onTakePhoto;
  final VoidCallback? onRemovePhoto;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = (photoUrl ?? '').trim().isNotEmpty;
    final canInteract = isEditable && !isPhotoLoading;

    return _Card(
      child: Row(
        children: [
          _Avatar(
            photoUrl: photoUrl,
            isLoading: isPhotoLoading,
            isEditable: isEditable,
            onEditTap: canInteract
                ? () => _showAvatarActions(context, hasPhoto: hasPhoto)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAvatarActions(BuildContext context, {required bool hasPhoto}) {
    showProfilePhotoActionsSheet(
      context,
      hasPhoto: hasPhoto,
      onChooseFromGallery: onChooseFromGallery,
      onTakePhoto: onTakePhoto,
      onRemovePhoto: onRemovePhoto,
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.photoUrl,
    required this.isLoading,
    required this.isEditable,
    required this.onEditTap,
  });

  final String? photoUrl;
  final bool isLoading;
  final bool isEditable;
  final VoidCallback? onEditTap;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = (photoUrl ?? '').trim().isNotEmpty;

    return SizedBox(
      width: 84,
      height: 84,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            type: MaterialType.transparency,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onEditTap,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppDecorations.avatar,
                  boxShadow: AppShadows.softElevation(),
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
                                photoUrl!,
                                fit: BoxFit.cover,
                                filterQuality: FilterQuality.high,
                                errorBuilder: (_, _, _) =>
                                    const _AvatarPlaceholder(),
                              ),
                            )
                          else
                            const Positioned.fill(child: _AvatarPlaceholder()),
                          if (isLoading)
                            Positioned.fill(
                              child: ColoredBox(
                                color: context.appColors.cardSurface.withValues(
                                  alpha: 0.60,
                                ),
                                child: const SizedBox.shrink(),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: isEditable
                ? Material(
                    color: context.appColors.cardSurface,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: onEditTap,
                      child: Container(
                        width: 32,
                        height: 32,
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
                  )
                : const SizedBox.shrink(),
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
        size: 36,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: appCardDecoration(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: child,
      ),
    );
  }
}
