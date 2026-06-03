# How to add new flavor (for example `stage`)

## Android
1. Duplicate `dev` folder in `/android/app/src` and rename it to `stage`. 
Change content in `res` if needed. Remove `google-serivces.json` file.(if any)
2. `/android/app/build.gradle` - find `productFlavors` and duplicate config for `stage` changing needed params.
## iOS
1. Duplicate `dev` folder in `/ios/config/src` and rename it to `stage`.
Remove `firebase_app_id_file.json` and `GoogleService-Info.plist`.(if any)
2. Open Xcode -> Project -> Runner -> Under the Info tab at the end of the Configurations dropdown list, click the plus button and duplicate each configuration name (Debug, Release, and Profile). Duplicate the existing configurations, once for each environment:
`Debug-dev` to `Debug-stage`, `Profile-dev` to `Profile-stage`, `Release-dev` to `Release-stage`.
3. Select Product > Scheme > Manage schemes -> Select `dev` -> Click tree dots icon -> Duplicate.
Open `Build` -> Pre-actions -> Change `ENV` to `stage` (it is important script which moves needed firebase file to needed folder according to flavor)
4. Open `Run` -> Info tab -> Build configuration -> Change `Debug-dev` to `Debug-stage`. Do same by analogy for `Test`, `Analyze`, `Profile`, `Archive`
5. Pop to main screen of Xcode -> Targets -> Runner -> Build settings:
Change the app bundle identifier to differentiate between schemes. In `Product Bundle Identifier`, append .stage to each stage scheme value.
6. Update `APP_NAME`, `PRODUCT_FLAVOR` in the same way
7. If needed, update `Primary App Icon Set Name`, but it would require you to add new icons. 


## Flutter
1. Open `/lib/firebase` and duplicate `dev` renaming to `stage`. Remove duplicated `firebase_options.dart`(if any)
2. Open `app_flavor.dart` and add `stage` to every place similarly.
3. Open `app_utils.dart` and add new credentials file in `_credentialsFileForFlavor()`. As well add real file `assets/config_stage.json`.
4. Add script with new flavor to `.gitlab-ci.yml` and to `/scripts/configure_env.sh` (find similar lines for dev/prod)
```shell
- cp -rf lib/firebase/dummy/firebase_options.dart lib/firebase/stage/
```

5. Duplicate `configure_envs_dev.sh` changing the name and content according to new flavor.
```shell
sh ./scripts/configure_envs.sh {flavor} {firebase_project_id} {android_package_name} {ios_bundle_id} {web_app_id}
```

## Web
Open `/webenv` and duplicate `dev` changing the name/content.



