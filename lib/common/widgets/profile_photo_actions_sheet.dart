import 'package:daily_water_tracker/common/widgets/app_bottom_sheet.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Gallery / camera / remove actions shared by Account and My Profile screens
Future<void> showProfilePhotoActionsSheet(
  BuildContext context, {
  required bool hasPhoto,
  required VoidCallback onChooseFromGallery,
  required VoidCallback onTakePhoto,
  VoidCallback? onRemovePhoto,
}) {
  return showAppBottomSheet<void>(
    context: context,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBottomSheetTitle(LocaleKeys.account_photo_sheet_title.tr()),
        AppBottomSheetAction(
          icon: Icons.photo_library_outlined,
          title: LocaleKeys.account_photo_gallery.tr(),
          onTap: () {
            Navigator.of(context).pop();
            onChooseFromGallery();
          },
        ),
        AppBottomSheetAction(
          icon: Icons.photo_camera_outlined,
          title: LocaleKeys.account_photo_camera.tr(),
          onTap: () {
            Navigator.of(context).pop();
            onTakePhoto();
          },
        ),
        if (hasPhoto && onRemovePhoto != null) ...[
          AppBottomSheetAction(
            icon: Icons.delete_outline,
            title: LocaleKeys.account_photo_remove.tr(),
            titleColor: Theme.of(context).colorScheme.error,
            onTap: () {
              Navigator.of(context).pop();
              onRemovePhoto();
            },
          ),
        ],
      ],
    ),
  );
}
