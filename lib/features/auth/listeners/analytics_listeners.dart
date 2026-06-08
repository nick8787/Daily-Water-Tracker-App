import 'package:daily_water_tracker/common/di/injector_module.dart';
import 'package:daily_water_tracker/common/services/analytics_service.dart';
import 'package:daily_water_tracker/firebase/services/auth_service.dart';
import 'package:flutter/material.dart';

class AnalyticsListeners extends StatefulWidget {
  final Widget child;

  const AnalyticsListeners({
    super.key,
    required this.child,
  });

  @override
  State<AnalyticsListeners> createState() => _AnalyticsListenersState();
}

class _AnalyticsListenersState extends State<AnalyticsListeners> {
  @override
  void initState() {
    super.initState();
    InjectorModule.locator<AuthService>().authStateChanges().listen((user) {
      if (mounted) {
        InjectorModule.locator<AnalyticsService>()
            .setAnalyticAndCrashlyticsUser(user: user);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
