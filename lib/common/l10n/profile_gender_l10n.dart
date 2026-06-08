import 'package:daily_water_tracker/features/profile/models/profile_gender.dart';
import 'package:easy_localization/easy_localization.dart';
extension ProfileGenderL10n on ProfileGender {
  String get localizedLabel {
    switch (this) {
      case ProfileGender.male:
        return 'profile.gender.male'.tr();
      case ProfileGender.female:
        return 'profile.gender.female'.tr();
      case ProfileGender.other:
        return 'profile.gender.other'.tr();
    }
  }
}
