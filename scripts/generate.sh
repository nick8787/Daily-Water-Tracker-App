# Localization
flutter pub run easy_localization:generate --source-dir assets/i18n
flutter pub run easy_localization:generate -f keys -o locale_keys.g.dart --source-dir assets/i18n
# Boilerplate for models, images etc.
flutter pub run build_runner build --delete-conflicting-outputs
