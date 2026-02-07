/// Dynamic page renderer.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/core.dart';
import '../../design/design.dart';
import '../../state/state.dart';
import '../../widgets/shared/shared.dart';

/// Renders a dynamic page from BFF page descriptor
class PageRenderer extends ConsumerWidget {
  const PageRenderer({
    required this.pageId,
    this.params = const {},
    super.key,
  });

  /// Page ID to load
  final String pageId;

  /// Route parameters (e.g., {id: "123"})
  final Map<String, String> params;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageAsync = ref.watch(pageProvider(pageId));

    return pageAsync.when(
      data: (page) => _PageContent(
        page: page,
        params: params,
      ),
      loading: () => const Scaffold(
        body: Center(
          child: AppLoadingIndicator(
            message: 'Loading page...',
          ),
        ),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: AppErrorWidget(
            error: error,
            onRetry: () => ref.invalidate(pageProvider(pageId)),
          ),
        ),
      ),
    );
  }
}

/// Page content renderer
class _PageContent extends StatelessWidget {
  const _PageContent({
    required this.page,
    required this.params,
  });

  final PageDescriptor page;
  final Map<String, String> params;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(page.title),
        actions: [
          // TODO: Render page actions from page.actions
          // For now, just show a placeholder
          if (page.actions.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                // TODO: Show actions menu
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // TODO: Render breadcrumbs if available
            if (page.breadcrumbs.isNotEmpty) ...[
              _Breadcrumbs(items: page.breadcrumbs),
              const SizedBox(height: AppSpacing.space16),
            ],

            // Render components
            ...page.components
                .where((component) => component.permission.allowed)
                .map(
                  (component) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.space16),
                    child: _ComponentPlaceholder(component: component),
                  ),
                ),

            // Empty state if no visible components
            if (page.components
                .where((component) => component.permission.allowed)
                .isEmpty)
              const AppEmptyState(
                message: 'This page has no content',
                icon: Icons.description,
              ),
          ],
        ),
      ),
    );
  }
}

/// Breadcrumb navigation
class _Breadcrumbs extends StatelessWidget {
  const _Breadcrumbs({required this.items});

  final List<BreadcrumbItem> items;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) ...[
            const SizedBox(width: AppSpacing.space8),
            const Icon(Icons.chevron_right, size: 16),
            const SizedBox(width: AppSpacing.space8),
          ],
          if (items[i].path != null)
            InkWell(
              onTap: () {
                // TODO: Navigate to breadcrumb path
              },
              child: Text(
                items[i].label,
                style: AppTypography.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            )
          else
            Text(
              items[i].label,
              style: AppTypography.bodySmall,
            ),
        ],
      ],
    );
  }
}

/// Component placeholder (TODO: implement actual component rendering)
class _ComponentPlaceholder extends StatelessWidget {
  const _ComponentPlaceholder({required this.component});

  final ComponentDescriptor component;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      title: component.type,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Component ID: ${component.id}'),
          Text('Type: ${component.type}'),
          if (component.config != null)
            Text('Config: ${component.config.toString()}'),
        ],
      ),
    );
  }
}
