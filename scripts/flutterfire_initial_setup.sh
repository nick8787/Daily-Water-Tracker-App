set -e # exit on first failed command
set -x # Print all executed commands to the log

############### LOCAL:
if [ "$CI" = false ] ;
then
  firebase login
fi

############### COMMON:

# Install flutterfire_cli
dart pub global activate flutterfire_cli

