import 'package:equatable/equatable.dart';

/// Unsaved profile photo change on My Profile (applied only on Save)
sealed class ProfilePhotoDraft extends Equatable {
  const ProfilePhotoDraft();
}

class ProfilePhotoDraftNone extends ProfilePhotoDraft {
  const ProfilePhotoDraftNone();

  @override
  List<Object?> get props => [];
}

class ProfilePhotoDraftPick extends ProfilePhotoDraft {
  const ProfilePhotoDraftPick(this.localPath);

  final String localPath;

  @override
  List<Object?> get props => [localPath];
}

class ProfilePhotoDraftRemove extends ProfilePhotoDraft {
  const ProfilePhotoDraftRemove();

  @override
  List<Object?> get props => [];
}
