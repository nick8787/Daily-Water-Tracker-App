set -e # exit on first failed command
set -x # Print all executed commands to the log

############### CODEMAGIC:
if [ "$CI" = true ] ;
then
  if [ "$CM_BUILD_STEP_STATUS" != "success" ]
    then
      echo "Skipping deploy since build failed!"
      exit 1
  fi
  echo 'Codemagic'
  # Deploy on Firebase Hosting using service account
  PROJECT_ROOT=$FCI_BUILD_DIR
  echo $FIREBASE_SERVICE_ACCOUNT | base64 --decode > $PROJECT_ROOT/service_account.json
  export GOOGLE_APPLICATION_CREDENTIALS=$PROJECT_ROOT/service_account.json
  firebase -P $FB_PROJECT_ID deploy
  # Remove service account
  rm $GOOGLE_APPLICATION_CREDENTIALS

############### LOCAL:
else
  echo 'LOCAL'
  firebase deploy
fi