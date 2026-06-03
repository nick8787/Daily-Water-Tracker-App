import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daily_water_tracker/common/assets.dart';
import 'package:daily_water_tracker/data/repositories/firestore_repository.dart';
import 'package:daily_water_tracker/data/repositories/messaging_repository.dart';
import 'package:daily_water_tracker/features/splash/cubit/splash_cubit.dart';
import 'package:daily_water_tracker/features/splash/cubit/splash_state.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';

import '../router.dart';

const splashLoginHeroTag = 'splashLoginHeroTag';
// Match native LaunchScreen placement
const _wordmarkVerticalBias = 0.40;
const _fadeBackgroundDuration = Duration(milliseconds: 220);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _showLaunchBackground = Platform.isIOS;
  bool _navigating = false;

  Future<void> _navigateAfterBackgroundFade(VoidCallback navigate) async {
    if (_navigating) return;
    _navigating = true;

    FlutterNativeSplash.remove();
    if (!Platform.isIOS) {
      // Ensure the router has finished its first build before navigating.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        // Extra microtask deferral avoids go_router match assertions on cold start
        // when an initial deep link is applied immediately.
        Future<void>.microtask(() {
          if (mounted) navigate();
        });
      });
      return;
    }

    if (mounted) setState(() => _showLaunchBackground = false);
    await Future<void>.delayed(_fadeBackgroundDuration);

    if (mounted) navigate();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = SplashCubit(
          firestoreRepository: context.read<FirestoreRepository>(),
          messagingRepository: context.read<MessagingRepository>(),
        );
        // On Android the splash init may complete "immediately" and emit a navigation state
        // before BlocListener subscribes. Running it post-frame guarantees the listener catches it.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (cubit.isClosed) return;
          cubit.initializeApp();
        });
        return cubit;
      },
      child: BlocListener<SplashCubit, SplashState>(
        listener: (context, state) {
          if (state is SplashNavigateToLogin) {
            _navigateAfterBackgroundFade(() {
              // On iOS keep stack-based navigation to preserve the Hero animation.
              // On Android use `go()` to avoid go_router matching assertions on cold start.
              if (Platform.isIOS) {
                // Keep using context-based pushReplacement for Hero transition.
                context.pushReplacement(loginRoute);
              } else {
                // Use global router to avoid context/location races on cold start.
                goRouter.go(loginRoute);
              }
            });
          } else if (state is SplashNavigateToAccount) {
            _navigateAfterBackgroundFade(() => goRouter.go(accountRoute));
          } else if (state is SplashNavigateToHome) {
            _navigateAfterBackgroundFade(() => goRouter.go(homeRoute));
          }
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Stack(
            fit: StackFit.expand,
            children: [
              if (Platform.isIOS)
                AnimatedOpacity(
                  opacity: _showLaunchBackground ? 1 : 0,
                  duration: _fadeBackgroundDuration,
                  curve: Curves.easeOut,
                  child: const Image(
                    image: AssetImage(splashLaunchBackground),
                    fit: BoxFit.cover,
                  ),
                ),
              SafeArea(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Align(
                      alignment: const Alignment(0, _wordmarkVerticalBias),
                      // iOS: show native-like launch background + Hero wordmark transition.
                      // Android: also render the wordmark to avoid a blank screen on deep-link cold start.
                      child: Hero(
                        tag: splashLoginHeroTag,
                        child: const Image(
                          image: AssetImage(splashWordmark),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
