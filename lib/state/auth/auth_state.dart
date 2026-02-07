/// Authentication state model.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.freezed.dart';
part 'auth_state.g.dart';

/// Authentication state
@freezed
class AuthState with _$AuthState {
  /// User is logged out
  const factory AuthState.loggedOut() = _LoggedOut;

  /// Login in progress
  const factory AuthState.loggingIn() = _LoggingIn;

  /// User is logged in
  const factory AuthState.loggedIn({
    required String accessToken,
    required String refreshToken,
    String? userId,
    String? username,
  }) = _LoggedIn;

  /// Authentication error
  const factory AuthState.error({
    required String message,
  }) = _AuthError;
}
