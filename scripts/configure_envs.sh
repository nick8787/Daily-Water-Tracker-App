# EXPLANATION:
# It creates `ios/Runner/GoogleService-Info.plist`
# It creates `ios/firebase_app_id_file.json`
# It creates `android/app/google-services.json`
# It creates `lib/firebase_options.dart`

set -e # exit on first failed command
set -x # Print all executed commands to the log

FLAVOR=$1
FIREBASE_PROJECT_ID=$2
ANDROID_PACKAGE_NAME=$3
IOS_BUNDLE_ID=$4

if [ "$CI" = true ] ;
then

  # Prepare service account
  PROJECT_ROOT=$FCI_BUILD_DIR
  echo $FIREBASE_SERVICE_ACCOUNT | base64 --decode > $PROJECT_ROOT/service_account.json
  # Run Flutterfire configure using service account
  export GOOGLE_APPLICATION_CREDENTIALS=$FCI_BUILD_DIR/service_account.json

  # Need some dummy file for unused flavor
  cp -rf lib/firebase/dummy/firebase_options.dart lib/firebase/dev/
  cp -rf lib/firebase/dummy/firebase_options.dart lib/firebase/prod/
fi


flutterfire configure \
--yes \
--project=$FIREBASE_PROJECT_ID \
--out=lib/firebase/$FLAVOR/firebase_options.dart \
--platforms=ios,android \
--android-package-name=$ANDROID_PACKAGE_NAME \
--ios-bundle-id=$IOS_BUNDLE_ID

if [ "$CI" = true ] ;
then
  # Remove service account
  rm $GOOGLE_APPLICATION_CREDENTIALS
fi

mv android/app/google-services.json android/app/src/$FLAVOR/google-services.json
mv ios/Runner/GoogleService-Info.plist ios/config/$FLAVOR/GoogleService-Info.plist
mv ios/firebase_app_id_file.json ios/config/$FLAVOR/firebase_app_id_file.json

echo "Setup finished"
