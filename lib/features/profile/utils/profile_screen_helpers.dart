import 'package:daily_water_tracker/features/profile/cubit/profile_state.dart';
import 'package:daily_water_tracker/features/profile/models/profile_photo_draft.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

String seedProfileFullName({
  required String? firstName,
  required String? lastName,
  required String? userName,
  required String? authDisplayName,
}) {
  final u = (userName ?? '').trim();
  if (u.isNotEmpty) return u;

  final parts = seedProfileNameFields(
    firstName: firstName,
    lastName: lastName,
    userName: userName,
    authDisplayName: authDisplayName,
  );
  final combined = '${parts.$1} ${parts.$2}'.trim();
  if (combined.isNotEmpty) return combined;

  return (authDisplayName ?? '').trim();
}

(String, String) seedProfileNameFields({
  required String? firstName,
  required String? lastName,
  required String? userName,
  required String? authDisplayName,
}) {
  final fn = (firstName ?? '').trim();
  final ln = (lastName ?? '').trim();
  if (fn.isNotEmpty || ln.isNotEmpty) return (fn, ln);

  final full = (userName ?? '').trim().isNotEmpty
      ? (userName ?? '').trim()
      : (authDisplayName ?? '').trim();
  if (full.isEmpty) return ('', '');

  final parts = full
      .split(RegExp(r'\s+'))
      .where((p) => p.trim().isNotEmpty)
      .toList();
  if (parts.isEmpty) return ('', '');
  if (parts.length == 1) return (parts.first, '');
  return (parts.first, parts.sublist(1).join(' '));
}

String profileAvatarUrl({
  required User? authUser,
  required String? profileUrl,
}) {
  final p = (profileUrl ?? '').trim();
  if (p.isNotEmpty) return p;
  return (authUser?.photoURL ?? '').trim();
}

class ProfileAvatarPreview {
  const ProfileAvatarPreview({
    this.networkUrl,
    this.localPath,
  });

  final String? networkUrl;
  final String? localPath;

  bool get hasPhoto =>
      (localPath ?? '').trim().isNotEmpty || (networkUrl ?? '').trim().isNotEmpty;
}

ProfileAvatarPreview profileAvatarPreview({
  required ProfileLoaded loaded,
  required User? authUser,
}) {
  final draft = loaded.photoDraft;
  if (draft is ProfilePhotoDraftPick) {
    return ProfileAvatarPreview(localPath: draft.localPath);
  }
  if (draft is ProfilePhotoDraftRemove) {
    return const ProfileAvatarPreview();
  }

  final url = profileAvatarUrl(
    authUser: authUser,
    profileUrl: loaded.profile.photoUrl,
  );
  return url.isEmpty
      ? const ProfileAvatarPreview()
      : ProfileAvatarPreview(networkUrl: url);
}

bool profileAvatarShowsRemoveAction({
  required ProfileLoaded loaded,
}) {
  final draft = loaded.photoDraft;
  if (draft is ProfilePhotoDraftRemove) return false;
  if (draft is ProfilePhotoDraftPick) return true;
  return (loaded.profile.photoId ?? '').trim().isNotEmpty;
}

String profileMemberSince(User? authUser) {
  final created = authUser?.metadata.creationTime;
  if (created == null) return '-';
  return DateFormat('d MMM, y').format(created);
}

int profileTotalDays(User? authUser) {
  final created = authUser?.metadata.creationTime;
  if (created == null) return 0;
  final start = DateTime(created.year, created.month, created.day);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return today.difference(start).inDays + 1;
}
