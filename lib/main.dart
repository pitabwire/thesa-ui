/// Main entry point for Thesa UI
///
/// This file initializes the application and starts the Flutter framework.
/// It sets up:
/// - Drift database for offline-first caching
/// - Flutter Secure Storage for auth token persistence
/// - Riverpod ProviderScope for state management
/// - Telemetry and error reporting
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

import 'package:stawi_theme/stawi_theme.dart';

import 'app/routing/router_provider.dart';

/// Logger for main.dart
final _logger = Logger('main');

/// Main entry point
///
/// This function is called by the Dart runtime when the app starts.
/// It performs initialization and launches the app.
Future<void> main() async {
  // Ensure Flutter bindings are initialized before any async operations
  WidgetsFlutterBinding.ensureInitialized();

  // Set up logging
  _setupLogging();

  _logger.info('Thesa UI starting...');

  // Run the app in a guarded zone to catch all errors
  await runZonedGuarded<Future<void>>(
    () async {
      // TODO: Initialize database (Drift)
      // final database = await _initializeDatabase();

      // TODO: Initialize secure storage for auth tokens
      // final secureStorage = await _initializeSecureStorage();

      // TODO: Set up telemetry
      // await _initializeTelemetry();

      _logger.info('Initialization complete. Launching app...');

      // Launch the app with Riverpod
      runApp(
        // ProviderScope is the root of all Riverpod providers
        const ProviderScope(
          // TODO: Pass overrides for database, storage, etc.
          // overrides: [
          //   databaseProvider.overrideWithValue(database),
          //   secureStorageProvider.overrideWithValue(secureStorage),
          // ],
          child: ThesaApp(),
        ),
      );
    },
    (error, stack) {
      // Global error handler
      _logger.severe('Uncaught error in app', error, stack);
      // TODO: Report to telemetry service
    },
  );
}

/// Sets up logging for the application
///
/// Configures the logging package to:
/// - Print to console in debug mode
/// - Send to telemetry in production
/// - Use appropriate log levels
void _setupLogging() {
  // Set log level based on build mode
  Logger.root.level = kDebugMode ? Level.ALL : Level.INFO;

  // Configure log output
  Logger.root.onRecord.listen((record) {
    final message = '${record.level.name}: ${record.time}: '
        '${record.loggerName}: ${record.message}';

    if (kDebugMode) {
      // Print to console in debug mode
      // ignore: avoid_print
      print(message);

      if (record.error != null) {
        // ignore: avoid_print
        print('Error: ${record.error}');
      }
      if (record.stackTrace != null) {
        // ignore: avoid_print
        print('Stack trace: ${record.stackTrace}');
      }
    } else {
      // TODO: Send to telemetry service in production
    }
  });
}

/// Main Thesa UI application widget
class ThesaApp extends ConsumerWidget {
  const ThesaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Thesa UI',
      debugShowCheckedModeBanner: false,
      theme: StawiTheme.light(),
      darkTheme: StawiTheme.dark(),
      themeMode: ThemeMode.dark, // Default to dark for modern look
      routerConfig: router,
    );
  }
}
