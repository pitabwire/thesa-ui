/// Telemetry interceptor for recording API request metrics.
///
/// Records:
/// - Request duration
/// - Status code
/// - Endpoint
/// - Success/failure
/// - Retry count
library;

import 'package:dio/dio.dart';
import 'package:logging/logging.dart';

/// Telemetry data for a request
class RequestTelemetry {
  RequestTelemetry({
    required this.endpoint,
    required this.method,
    required this.startTime,
    this.endTime,
    this.statusCode,
    this.error,
    this.retryCount = 0,
  });

  final String endpoint;
  final String method;
  final DateTime startTime;
  DateTime? endTime;
  int? statusCode;
  Object? error;
  int retryCount;

  /// Calculate request duration in milliseconds
  int? get durationMs {
    if (endTime == null) return null;
    return endTime!.difference(startTime).inMilliseconds;
  }

  /// Whether the request was successful
  bool get isSuccess => statusCode != null && statusCode! >= 200 && statusCode! < 300;
}

/// Telemetry interceptor
class TelemetryInterceptor extends Interceptor {
  TelemetryInterceptor();

  final _logger = Logger('TelemetryInterceptor');

  // Store telemetry data keyed by request ID
  final Map<String, RequestTelemetry> _telemetryData = {};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Record start time
    final requestId = _getRequestId(options);
    _telemetryData[requestId] = RequestTelemetry(
      endpoint: options.path,
      method: options.method,
      startTime: DateTime.now(),
    );

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final requestId = _getRequestId(response.requestOptions);
    final telemetry = _telemetryData[requestId];

    if (telemetry != null) {
      telemetry.endTime = DateTime.now();
      telemetry.statusCode = response.statusCode;

      // Emit telemetry event
      _emitTelemetry(telemetry);

      // Clean up
      _telemetryData.remove(requestId);
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final requestId = _getRequestId(err.requestOptions);
    final telemetry = _telemetryData[requestId];

    if (telemetry != null) {
      telemetry.endTime = DateTime.now();
      telemetry.statusCode = err.response?.statusCode;
      telemetry.error = err;

      // Emit telemetry event
      _emitTelemetry(telemetry);

      // Clean up
      _telemetryData.remove(requestId);
    }

    handler.next(err);
  }

  /// Emit telemetry event
  void _emitTelemetry(RequestTelemetry telemetry) {
    // Log the telemetry data
    final duration = telemetry.durationMs ?? 0;
    final status = telemetry.statusCode ?? 0;

    if (telemetry.isSuccess) {
      _logger.fine(
        'API ${telemetry.method} ${telemetry.endpoint} '
        'completed in ${duration}ms (${status})',
      );
    } else {
      _logger.warning(
        'API ${telemetry.method} ${telemetry.endpoint} '
        'failed after ${duration}ms (${status})',
      );
    }

    // TODO: Send to telemetry service (OpenTelemetry)
    // This will be implemented in the telemetry module
    /*
    telemetryService.recordEvent(
      'api.request',
      {
        'endpoint': telemetry.endpoint,
        'method': telemetry.method,
        'durationMs': telemetry.durationMs,
        'statusCode': telemetry.statusCode,
        'success': telemetry.isSuccess,
        'retryCount': telemetry.retryCount,
      },
    );
    */
  }

  /// Generate a unique ID for a request
  String _getRequestId(RequestOptions options) {
    // Use object hash code as a simple ID
    return options.hashCode.toString();
  }

  /// Get telemetry data for debugging
  Map<String, RequestTelemetry> get activeTelemetry => Map.unmodifiable(_telemetryData);
}
