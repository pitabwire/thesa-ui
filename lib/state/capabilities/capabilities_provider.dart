/// Capabilities provider for global feature flags and version.
///
/// Cache-first with 15-minute TTL.
/// Always alive - never disposed.
library;

import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../cache/cache_policy.dart';
import '../../core/core.dart';
import '../core/dependencies_provider.dart';

part 'capabilities_provider.g.dart';

final _logger = Logger('CapabilitiesProvider');

/// Capabilities provider
@Riverpod(keepAlive: true)
class CapabilitiesNotifier extends _$CapabilitiesNotifier {
  @override
  Future<Capabilities> build() async {
    _logger.info('Loading capabilities');

    final cacheCoordinator = await ref.read(cacheCoordinatorProvider.future);
    final bffClient = ref.read(bffClientProvider);

    try {
      // Use 'global' as the fixed ID for capabilities
      final result = await cacheCoordinator.getCapabilities(
        'global',
        fetchFromNetwork: () => bffClient.getCapabilities(),
      );

      _logger.info(
        'Capabilities loaded: ${result.state.name} '
        '(version ${result.data.version})',
      );

      return result.data;
    } catch (e, stack) {
      _logger.severe('Failed to load capabilities', e, stack);
      rethrow;
    }
  }

  /// Refresh capabilities from server
  Future<void> refresh() async {
    _logger.info('Refreshing capabilities');
    ref.invalidateSelf();
  }

  /// Check if a feature is enabled
  bool isFeatureEnabled(String feature) {
    return state.valueOrNull?.capabilities[feature]?.enabled ?? false;
  }

  /// Get global version for cache invalidation
  String? get globalVersion => state.valueOrNull?.version;
}
