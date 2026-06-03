import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:daily_water_tracker/common/di/injector_module.dart';
import 'package:daily_water_tracker/common/services/analytics_service.dart';
import 'package:daily_water_tracker/common/services/app_bootstrapper.dart';
import 'package:daily_water_tracker/data/repositories/firestore_repository.dart';
import 'package:daily_water_tracker/data/repositories/messaging_repository.dart';
import 'package:daily_water_tracker/data/repositories/storage_repository.dart';
import 'package:daily_water_tracker/firebase/services/auth_service.dart';
import 'package:daily_water_tracker/firebase/services/local_notifications_service.dart';
import 'package:daily_water_tracker/firebase/services/reminder_scheduler_service.dart';
import 'package:daily_water_tracker/firebase/services/user_account_deletion_service.dart';

class RepositoriesHolder extends StatelessWidget {
  const RepositoriesHolder({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<FirestoreRepository>(
          lazy: false,
          create: (_) => FirestoreRepository(
            analytics: InjectorModule.locator<AnalyticsService>(),
            auth: FirebaseAuth.instance,
            firestore: FirebaseFirestore.instance,
          ),
        ),
        RepositoryProvider<StorageRepository>(
          lazy: false,
          create: (_) => StorageRepository(
            storage: FirebaseStorage.instance,
          ),
        ),
        RepositoryProvider<MessagingRepository>(
          lazy: false,
          create: (context) {
            final repository = MessagingRepository(
              messaging: FirebaseMessaging.instance,
              authService: InjectorModule.locator<AuthService>(),
              firestoreRepository: context.read<FirestoreRepository>(),
              localNotifications:
                  InjectorModule.locator<LocalNotificationsService>(),
            );
            // Hydrate the cold-start pending route before Splash consumes it.
            unawaited(repository.hydratePendingRouteFromColdStart());
            return repository;
          },
        ),
        RepositoryProvider<ReminderSchedulerService>(
          lazy: false,
          create: (context) {
            final messaging = context.read<MessagingRepository>();
            return ReminderSchedulerService(
              authService: InjectorModule.locator<AuthService>(),
              firestoreRepository: context.read<FirestoreRepository>(),
              localNotifications:
                  InjectorModule.locator<LocalNotificationsService>(),
              isDevBuild: () => flutterFlavor.isDev,
              onAfterReminderPipeline:
                  messaging.syncReminderTopicWithPreferences,
            );
          },
        ),
        RepositoryProvider<UserAccountDeletionService>(
          create: (context) => UserAccountDeletionService(
            authService: InjectorModule.locator<AuthService>(),
            firestoreRepository: context.read<FirestoreRepository>(),
            storageRepository: context.read<StorageRepository>(),
            messagingRepository: context.read<MessagingRepository>(),
            reminderScheduler: context.read<ReminderSchedulerService>(),
          ),
        ),
      ],
      child: child,
    );
  }
}
