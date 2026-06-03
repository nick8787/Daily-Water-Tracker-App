import 'package:firebase_auth/firebase_auth.dart';

String accountDisplayNameFromUser(User? user) {
  final name = (user?.displayName ?? '').trim();
  if (name.isNotEmpty) return name;

  final email = (user?.email ?? '').trim();
  if (email.isEmpty) return 'User';

  final at = email.indexOf('@');
  if (at <= 0) return email;
  return email.substring(0, at);
}
