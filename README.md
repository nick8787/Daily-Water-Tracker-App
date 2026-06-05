# Daily Water Tracker

A Flutter app for tracking daily water intake. Backed by Firebase, with real-time sync, push reminders, server-driven UI and a full Codemagic CI/CD pipeline for Android and iOS

## 🎬 Demo

<video src="docs/app%20demo.mp4" controls width="100%"></video>

[docs/app demo.mp4](docs/app%20demo.mp4)

## 🚀 Features

- Sign in with email/password, Google, Apple or Facebook (Facebook is dev-only)
- Real-time hydration log on Firestore, with hydration coefficients per drink type (water, tea, coffee, milk)
- Daily goal: either calculated from weight or set manually
- Push reminders via FCM with quiet hours and topic subscription
- Local scheduled reminders, timezone-aware
- Remote Config for switching the progress indicator style (circular / linear) and showing an emergency banner without shipping a new build
- Shareable "today" link that opens straight into the app (App Links via Firebase Hosting, dev-only)
- Profile + avatar upload to Firebase Storage
- Account deletion flow with reauthentication
- EN / UK localisation
- Light / dark theme
- Firebase Analytics screen tracking and Crashlytics non-fatal reporting
- Offline banner when the device loses connectivity

## 🛠 Tech Stack

- **Flutter** (stable) and **Dart 3.8**
- **State management:** `flutter_bloc`
- **DI:** `RepositoryProvider` for the stateful stuff (repositories, services), `get_it` for the stateless platform utilities
- **Routing:** `go_router` with an Analytics observer
- **Networking:** `dio` with a refresh-token interceptor
- **Firebase:** Auth, Firestore, Storage, Messaging, Remote Config, Analytics, Crashlytics, App Check
- **Notifications:** `firebase_messaging`, `flutter_local_notifications`, `flutter_timezone`
- **Localisation:** `easy_localization`
- **CI/CD:** Codemagic

## 🏗 Project Structure

```
.
├── android/                  Android platform code, Gradle config
├── ios/                      iOS platform code, CocoaPods
├── assets/                   Fonts, images, SVGs, i18n JSON, runtime config
├── docs/                     Internal notes (flavors etc.)
├── lib/
│   ├── common/               App-wide widgets, services, utils, DI, router
│   ├── data/repositories/    Firestore / Storage / Messaging repositories
│   ├── features/             Feature-first modules (cubit + screens + widgets)
│   │   ├── account/
│   │   ├── auth/
│   │   ├── home/
│   │   ├── history/
│   │   ├── statistics/
│   │   ├── preferences/
│   │   ├── profile/
│   │   ├── notifications/
│   │   ├── locale/
│   │   ├── theme/
│   │   └── ...
│   ├── firebase/             Firebase services and models
│   ├── network/              Dio client, interceptors, WebSocket
│   └── main.dart             Entry point - DI, Firebase init, EasyLocalization
├── scripts/                  Codegen, l10n, icons, Firebase/env setup helpers
├── codemagic.yaml            CI/CD pipelines (dev + prod)
└── pubspec.yaml
```

## 📋 Prerequisites

- Flutter SDK 3.41.x (or compatible)
- Dart SDK ^3.8.0
- Android Studio / Xcode for native builds
- A Firebase project (Auth, Firestore, FCM, Storage, Remote Config, Crashlytics, App Check)

## 🔧 Getting Started

### 1. Pull packages

```shell
flutter pub get
```

### 2. Drop in the Firebase configs

These are gitignored, you bring your own:

```
android/app/src/dev/google-services.json
android/app/src/prod/google-services.json
ios/config/dev/GoogleService-Info.plist
ios/config/prod/GoogleService-Info.plist
```

### 3. Add the local runtime config

Two files under `assets/` (also gitignored):

- `assets/config_development.json`
- `assets/config_production.json`

Example:

```json
{
  "appName": "Daily Water Tracker",
  "apiBaseUrl": "https://your-api-url.com",
  "googleServerClientId": "YOUR_CLIENT_ID.apps.googleusercontent.com"
}
```

### 4. Run

The project has `dev` and `prod` flavors

```shell
flutter run --flavor dev
flutter run --flavor prod
```

## ⚙️ Development

### Generate models, assets, etc.

```shell
sh ./scripts/generate.sh
```

### Update localisation keys

```shell
sh ./scripts/generate_l10n.sh
```

### Generate launcher icons

```shell
sh ./scripts/generate_android_icons.sh
```

### Deploy `.well-known/assetlinks.json` (App Links)

```shell
sh ./scripts/firebase_hosting_deploy.sh
```

## 🤖 CI/CD

Pipelines live in [`codemagic.yaml`](./codemagic.yaml) and are split in two:

- **Development workflow** - runs on every push to `master`. Builds Android and iOS in `dev` flavor with `--build-name=0.0.<BUILD_NUMBER>`, then ships the artifacts to the Firebase App Distribution `internal-testers` group
- **Production workflow** - runs on a Git tag (`v*.*.*`). Takes the version from the tag, builds release Android/iOS in `prod` flavor, ships to Firebase App Distribution and TestFlight

Both workflows read release notes from a single `release_notes.json` 

## 📝 License

Licensed under the BSD-3-Clause License - see [`LICENSE.txt`](./LICENSE.txt) for details

## 👤 Author

**Created by Mykola Shchypailo**, 2026
