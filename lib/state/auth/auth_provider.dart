/// Authentication provider for managing login/logout state.
///
/// Always alive - never disposed.
library;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../networking/networking.dart';
import '../core/dependencies_provider.dart';
import 'auth_state.dart';

part 'auth_provider.g.dart';

final _logger = Logger('AuthProvider');

/// Auth provider
@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  @override
  Future<AuthState> build() async {
    // Check for existing token on startup
    final secureStorage = ref.read(secureStorageProvider);
    final accessToken = await AuthInterceptor.getAccessToken(secureStorage);
    final refreshToken = await AuthInterceptor.getRefreshToken(secureStorage);

    if (accessToken != null && refreshToken != null) {
      // Tokens exist, restore session with actual tokens
      _logger.info('Found existing tokens, restoring session');
      return AuthState.loggedIn(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    }

    return const AuthState.loggedOut();
  }

  /// Login with username and password
  Future<void> login(String username, String password) async {
    state = const AsyncValue.data(AuthState.loggingIn());

    try {
      _logger.info('Logging in user: $username');

      final bffClient = ref.read(bffClientProvider);
      final secureStorage = ref.read(secureStorageProvider);

      // Call BFF login endpoint
      final response = await bffClient.login(
        username: username,
        password: password,
      );

      final accessToken = response['access_token'] as String;
      final refreshToken = response['refresh_token'] as String;

      // Store tokens
      await AuthInterceptor.storeTokens(
        secureStorage: secureStorage,
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      state = AsyncValue.data(
        AuthState.loggedIn(
          accessToken: accessToken,
          refreshToken: refreshToken,
          username: username,
        ),
      );

      _logger.info('Login successful');
    } catch (e, stack) {
      _logger.severe('Login failed', e, stack);
      state = AsyncValue.data(
        AuthState.error(message: 'Login failed: ${e.toString()}'),
      );
    }
  }

  /// Logout
  Future<void> logout() async {
    _logger.info('Logging out');

    try {
      final bffClient = ref.read(bffClientProvider);
      final secureStorage = ref.read(secureStorageProvider);
      final cacheCoordinator = await ref.read(cacheCoordinatorProvider.future);

      // Call BFF logout endpoint
      await bffClient.logout();

      // Clear tokens
      await secureStorage.deleteAll();

      // Clear cache
      await cacheCoordinator.clearAll();

      state = const AsyncValue.data(AuthState.loggedOut());

      _logger.info('Logout successful');
    } catch (e, stack) {
      _logger.severe('Logout failed', e, stack);
      // Still mark as logged out even if cleanup fails
      state = const AsyncValue.data(AuthState.loggedOut());
    }
  }
}
