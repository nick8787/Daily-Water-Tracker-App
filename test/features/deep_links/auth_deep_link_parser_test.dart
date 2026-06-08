import 'package:daily_water_tracker/features/deep_links/services/auth_deep_link_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseAuthPasswordResetLink', () {
    test('parses prod /__/auth/action link from reset email', () {
      final uri = Uri.parse(
        'https://dailywatertracker-app-prod.web.app/__/auth/action'
        '?mode=resetPassword'
        '&oobCode=BUp7uwf3nx3Z8YMuEOn_0NdscDHq'
        '&apiKey=AIzaSyAFINLbi3isX703H20NFIjIohCXozIunUU'
        '&continueUrl=https%3A%2F%2Fdailywatertracker-app-prod.firebaseapp.com'
        '%2F__%2Fauth%2Flinks%3Flink%3Dhttps%3A%2F%2Fdailywatertracker-app-prod.web.app'
        '%2Fpassword-reset'
        '&lang=en',
      );

      final parsed = parseAuthPasswordResetLink(uri);

      expect(parsed, isNotNull);
      expect(parsed!.oobCode, 'BUp7uwf3nx3Z8YMuEOn_0NdscDHq');
    });

    test('parses nested /__/auth/links wrapper', () {
      final uri = Uri.parse(
        'https://dailywatertracker-app-prod.web.app/__/auth/links'
        '?link=https%3A%2F%2Fdailywatertracker-app-prod.web.app%2Fpassword-reset'
        '&mode=resetPassword'
        '&oobCode=test-code',
      );

      final parsed = parseAuthPasswordResetLink(uri);

      expect(parsed, isNotNull);
      expect(parsed!.oobCode, 'test-code');
    });

    test('builds complete-password-reset route', () {
      final uri = Uri.parse(
        'https://dailywatertracker-app-prod.web.app/password-reset'
        '?mode=resetPassword&oobCode=abc123',
      );

      final location = passwordResetRedirectLocation(uri);

      expect(
        location,
        '/login/complete-password-reset?oobCode=abc123',
      );
    });
  });
}
