/// Core dependency providers for shared services.
///
/// Provides BFF client, cache coordinator, and database instances.
library;

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../cache/cache_coordinator.dart';
import '../../cache/database/app_database.dart';
import '../../networking/bff_client.dart';
import '../../networking/dio_factory.dart';
import '../../telemetry/telemetry_provider.dart';

part 'dependencies_provider.g.dart';

/// Secure storage provider (singleton)
@Riverpod(keepAlive: true)
FlutterSecureStorage secureStorage(SecureStorageRef ref) {
  return const FlutterSecureStorage();
}

/// Dio instance provider (singleton)
@Riverpod(keepAlive: true)
Dio dio(DioRef ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  final telemetryService = ref.watch(telemetryServiceProvider);
  // TODO: Get baseUrl from config/environment
  const baseUrl = 'https://api.example.com';
  return DioFactory.create(
    baseUrl: baseUrl,
    secureStorage: secureStorage,
    telemetryService: telemetryService,
  );
}

/// BFF client provider (singleton)
@Riverpod(keepAlive: true)
BffClient bffClient(BffClientRef ref) {
  final dio = ref.watch(dioProvider);
  return BffClient(dio);
}

/// App database provider (singleton)
@Riverpod(keepAlive: true)
Future<AppDatabase> database(DatabaseRef ref) async {
  // Database will be disposed when app is closed
  final db = await createDatabase();
  ref.onDispose(() => db.close());
  return db;
}

/// Cache coordinator provider (singleton)
@Riverpod(keepAlive: true)
Future<CacheCoordinator> cacheCoordinator(CacheCoordinatorRef ref) async {
  final database = await ref.watch(databaseProvider.future);
  return CacheCoordinator(database);
}
