import 'dart:async';

import 'package:daily_water_tracker/common/di/injector_module.dart';
import 'package:daily_water_tracker/common/services/logger.dart';
import 'package:daily_water_tracker/data/repositories/firestore_repository.dart';
import 'package:daily_water_tracker/data/repositories/messaging_repository.dart';
import 'package:daily_water_tracker/firebase/services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit({
    required FirestoreRepository firestoreRepository,
    required MessagingRepository messagingRepository,
  })  : _firestoreRepository = firestoreRepository,
        _messagingRepository = messagingRepository,
        super(const SplashInitial());

  final FirestoreRepository _firestoreRepository;
  final MessagingRepository _messagingRepository;

  static const Duration _minSplashDurationIos = Duration(milliseconds: 1500);
  static const Duration _networkOpTimeout = Duration(seconds: 3);

  Future<void> initializeApp() async {
    emit(const SplashLoading());
    final start = DateTime.now();

    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }

      // Make sure the cold-start FCM route is hydrated before we read it.
      await _messagingRepository.hydratePendingRouteFromColdStart();

      final authService = InjectorModule.locator<AuthService>();
      final currentUser = authService.currentUser;
      final pendingRoute = _messagingRepository.peekPendingRoute();

      if (currentUser != null) {
        await _firestoreRepository.syncUserRootFromAuth().timeout(
              _networkOpTimeout,
              onTimeout: () => null,
            );
        unawaited(_messagingRepository.syncTokenNow());
      }

      final elapsed = DateTime.now().difference(start);
      final min = defaultTargetPlatform == TargetPlatform.iOS
          ? _minSplashDurationIos
          : Duration.zero;
      final remaining = min - elapsed;
      if (!remaining.isNegative) {
        await Future<void>.delayed(remaining);
      }

      if (currentUser != null) {
        _messagingRepository.consumePendingRoute();
        if ((pendingRoute ?? '').trim() == 'account') {
          emit(const SplashNavigateToAccount());
        } else {
          emit(const SplashNavigateToHome());
        }
      } else {
        emit(const SplashNavigateToLogin());
      }
    } catch (e, st) {
      logCaughtError('SplashCubit.initializeApp', e, st);
      final elapsed = DateTime.now().difference(start);
      final min = defaultTargetPlatform == TargetPlatform.iOS
          ? _minSplashDurationIos
          : Duration.zero;
      final remaining = min - elapsed;
      if (!remaining.isNegative) {
        await Future<void>.delayed(remaining);
      }
      emit(const SplashNavigateToLogin());
    }
  }
}
