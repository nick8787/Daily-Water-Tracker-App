# Daily Water Tracker

A Flutter app for tracking daily water intake. Backed by Firebase, with real-time sync, push reminders, server-driven UI and a full Codemagic CI/CD pipeline for Android and iOS

## 🎬 Demo

https://github.com/user-attachments/assets/1e6fd4eb-5a31-42e4-aa9f-3899c336d195

## 🚀 Features

- Sign in with email/password, Google, Apple or Facebook (Facebook is dev-only)
- Forgot password - reset link lands on a Firebase Hosting page, then back into the app
- Change password for email accounts (Login & security)
- Real-time hydration log on Firestore, with coefficients per drink type (water, tea, coffee, milk)
- History - past days and what you drank / edit records
- Statistics - weekly chart and summary
- Ranks / achievements - hydration evolution tiers (Beginner → Poseidon), unlock by logging, goal days, volume; popup when you rank up, optional share from there
- Share today's progress from Account - link with ml count; opens the app if installed, otherwise a hosting landing page (dev + prod)
- Daily goal from weight or set manually in Preferences
- Push reminders (FCM), quiet hours, topic subscription
- Local scheduled reminders, timezone-aware
- Remote Config - switch progress ring style (circular / linear) or show an emergency banner without a new build
- My Profile - name, weight, gender, avatar 
- Account header - avatar with gallery / camera / remove, saves straight away
- More - language (EN / UK), vibration on/off, log out, delete account (clears Firestore data, Storage files)
- Light / dark theme
- Firebase Analytics screen tracking and Crashlytics non-fatal reporting
- Offline banner when connectivity drops
- EN / UK localisation

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
├── public/                   Firebase Hosting — share page, password reset, app links
├── docs/                     Internal notes (flavors etc.)
├── lib/
│   ├── common/               App-wide widgets, services, utils, DI, router
│   ├── data/repositories/    Firestore / Storage / Messaging repositories
│   ├── features/             Feature-first modules (cubit + screens + widgets)
│   │   ├── account/
│   │   ├── achievements/
│   │   ├── auth/
│   │   ├── deep_links/
│   │   ├── home/
│   │   ├── history/
│   │   ├── login_security/
│   │   ├── statistics/
│   │   ├── preferences/
│   │   ├── profile/
│   │   ├── notifications/
│   │   ├── locale/
│   │   ├── theme/
│   │   ├── vibration/
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

### Regenerate hosting icons (share landing pages)

```shell
sh ./scripts/sync_hosting_app_icons.sh
```

### Deploy Firebase Hosting (share links, password reset, app links)

```shell
firebase deploy --only hosting -P prod
firebase deploy --only hosting -P dev
```

Or the older helper (uses default project from `.firebaserc`):

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
