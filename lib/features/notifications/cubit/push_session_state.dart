import 'package:equatable/equatable.dart';

/// One-shot navigation requested by push / local notification handling.
sealed class PushSessionNavigation extends Equatable {
  const PushSessionNavigation();

  @override
  List<Object?> get props => [];
}

/// User tapped a notification while signed out — store route and open login.
final class PushSessionNavigateLogin extends PushSessionNavigation {
  const PushSessionNavigateLogin();
}

/// Deep link or notification route to open (signed in or cold start).
final class PushSessionNavigateRoute extends PushSessionNavigation {
  const PushSessionNavigateRoute(this.route);

  final String? route;

  @override
  List<Object?> get props => [route];
}

class PushSessionState extends Equatable {
  const PushSessionState({
    this.isSignedIn = false,
    this.pendingNavigation,
  });

  final bool isSignedIn;
  final PushSessionNavigation? pendingNavigation;

  PushSessionState copyWith({
    bool? isSignedIn,
    PushSessionNavigation? pendingNavigation,
    bool clearNavigation = false,
  }) {
    return PushSessionState(
      isSignedIn: isSignedIn ?? this.isSignedIn,
      pendingNavigation:
          clearNavigation ? null : (pendingNavigation ?? this.pendingNavigation),
    );
  }

  @override
  List<Object?> get props => [isSignedIn, pendingNavigation];
}
