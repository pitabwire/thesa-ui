/// Router provider for dynamic routing.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../state/state.dart';
import 'dynamic_route_builder.dart';

part 'router_provider.g.dart';

/// GoRouter provider
@riverpod
GoRouter router(RouterRef ref) {
  // Watch navigation to rebuild routes when it changes
  final navigationAsync = ref.watch(navigationProvider);

  // Build routes from navigation tree
  final routes = navigationAsync.maybeWhen(
    data: (navigation) {
      final visibleItems =
          navigation.items.where((item) => item.permission.allowed).toList();
      return DynamicRouteBuilder.buildRoutes(visibleItems);
    },
    orElse: () => [
      // Loading state route
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    ],
  );

  return GoRouter(
    routes: routes,
    initialLocation: '/',
    debugLogDiagnostics: true,
    errorBuilder: (context, state) => _ErrorPage(error: state.error),
  );
}

/// Error page for routing errors
class _ErrorPage extends StatelessWidget {
  const _ErrorPage({required this.error});

  final Exception? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: 16),
            const Text('Page Not Found'),
            if (error != null) ...[
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
