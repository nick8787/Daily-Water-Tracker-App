class AccountLogoutUiFreeze {
  const AccountLogoutUiFreeze({
    required this.displayName,
    required this.email,
    required this.photoUrl,
    required this.hasCustomPhoto,
  });

  final String displayName;
  final String email;
  final String? photoUrl;
  final bool hasCustomPhoto;

  bool get hasAnyPhoto => (photoUrl ?? '').trim().isNotEmpty;
  bool get isEditable => !hasAnyPhoto || hasCustomPhoto;
}
