import 'package:daily_water_tracker/common/router.dart';
import 'package:daily_water_tracker/common/utils/local_notification_route_actions.dart';
import 'package:daily_water_tracker/features/notifications/cubit/push_session_cubit.dart';
import 'package:daily_water_tracker/features/notifications/cubit/push_session_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PushSessionListener extends StatefulWidget {
  const PushSessionListener({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<PushSessionListener> createState() => _PushSessionListenerState();
}

class _PushSessionListenerState extends State<PushSessionListener>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PushSessionCubit>().initializeColdStart();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || !mounted) return;
    context.read<PushSessionCubit>().onAppResumed();
  }

  static bool _listenWhen(PushSessionState prev, PushSessionState next) {
    return prev.pendingNavigation != next.pendingNavigation &&
        next.pendingNavigation != null;
  }

  static void _listener(BuildContext context, PushSessionState state) {
    final navigation = state.pendingNavigation;
    if (navigation == null) return;

    context.read<PushSessionCubit>().clearNavigation();

    switch (navigation) {
      case PushSessionNavigateLogin():
        goRouter.go(loginRoute);
      case PushSessionNavigateRoute(:final route):
        routeFromLocalNotificationTap(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PushSessionCubit, PushSessionState>(
      listenWhen: _listenWhen,
      listener: _listener,
      child: widget.child,
    );
  }
}
