set -e # exit on first failed command
set -x # Print all executed commands to the log

git-changelog generate --previous-commit=${CM_PREVIOUS_COMMIT} \
  `git rev-list --tags --skip=1  --max-count=1` > release_notes.txt


# Remove .json since we generate commit-based release notes, not translated-user-friendly production release notes.
rm release_notes.json
