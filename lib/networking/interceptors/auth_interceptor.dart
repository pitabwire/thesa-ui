/// Authentication interceptor for adding auth tokens and handling token refresh.
///
/// On request:
/// - Adds Authorization header with access token
///
/// On 401 response:
/// - Attempts to refresh the token
/// - Retries the original request with new token
/// - Navigates to login if refresh fails
library;

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';

/// Authentication interceptor
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.secureStorage});

  final FlutterSecureStorage secureStorage;
  final _logger = Logger('AuthInterceptor');

  // Mutex for token refresh to prevent concurrent refreshes
  Completer<String?>? _refreshCompleter;

  // Storage keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth for login/refresh endpoints
    if (options.path.contains('/auth/login') ||
        options.path.contains('/auth/refresh')) {
      return handler.next(options);
    }

    // Read access token from secure storage
    final accessToken = await secureStorage.read(key: _accessTokenKey);

    if (accessToken != null) {
      // Add authorization header
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Only handle 401 Unauthorized errors
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    _logger.info('Received 401, attempting token refresh');

    try {
      // Attempt to refresh the token
      final newAccessToken = await _refreshToken();

      if (newAccessToken == null) {
        // Refresh failed - clear session and navigate to login
        _logger.warning('Token refresh failed, clearing session');
        await _clearSession();
        return handler.reject(err);
      }

      // Retry the original request with the new token
      _logger.info('Token refreshed successfully, retrying request');
      final options = err.requestOptions;
      options.headers['Authorization'] = 'Bearer $newAccessToken';

      // Create a new Dio instance to avoid infinite loop
      final dio = Dio();
      final response = await dio.fetch(options);

      return handler.resolve(response);
    } catch (e, stack) {
      _logger.severe('Error during token refresh', e, stack);
      await _clearSession();
      return handler.reject(err);
    }
  }

  /// Refresh the access token using the refresh token
  Future<String?> _refreshToken() async {
    // If a refresh is already in progress, wait for it
    if (_refreshCompleter != null) {
      _logger.fine('Token refresh already in progress, waiting...');
      return _refreshCompleter!.future;
    }

    // Start a new refresh
    _refreshCompleter = Completer<String?>();

    try {
      final refreshToken = await secureStorage.read(key: _refreshTokenKey);

      if (refreshToken == null) {
        _logger.warning('No refresh token available');
        _refreshCompleter!.complete(null);
        return null;
      }

      // Call the refresh endpoint
      final dio = Dio();
      final response = await dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final newAccessToken = response.data!['access_token'] as String?;
        final newRefreshToken = response.data!['refresh_token'] as String?;

        if (newAccessToken != null) {
          // Store new tokens
          await secureStorage.write(key: _accessTokenKey, value: newAccessToken);
          if (newRefreshToken != null) {
            await secureStorage.write(
              key: _refreshTokenKey,
              value: newRefreshToken,
            );
          }

          _refreshCompleter!.complete(newAccessToken);
          return newAccessToken;
        }
      }

      _refreshCompleter!.complete(null);
      return null;
    } catch (e, stack) {
      _logger.severe('Token refresh request failed', e, stack);
      _refreshCompleter!.complete(null);
      return null;
    } finally {
      _refreshCompleter = null;
    }
  }

  /// Clear all auth tokens and session data
  Future<void> _clearSession() async {
    await secureStorage.delete(key: _accessTokenKey);
    await secureStorage.delete(key: _refreshTokenKey);
    // TODO: Clear cache, navigate to login screen
    // This will be implemented when we integrate with the state layer
  }

  /// Store auth tokens after successful login
  static Future<void> storeTokens({
    required FlutterSecureStorage secureStorage,
    required String accessToken,
    required String refreshToken,
  }) async {
    await secureStorage.write(key: _accessTokenKey, value: accessToken);
    await secureStorage.write(key: _refreshTokenKey, value: refreshToken);
  }

  /// Get the current access token
  static Future<String?> getAccessToken(
    FlutterSecureStorage secureStorage,
  ) async {
    return secureStorage.read(key: _accessTokenKey);
  }
}
