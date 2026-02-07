/// Form renderer with dynamic form engine.
///
/// Loads schema from schemaProvider and renders using DynamicForm.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../../../forms/forms.dart';
import '../../../state/state.dart';
import '../../../widgets/shared/shared.dart';

/// Renders form component with schema-driven dynamic forms
class FormRenderer extends ConsumerWidget {
  const FormRenderer({
    required this.component,
    this.params = const {},
    super.key,
  });

  final ComponentDescriptor component;
  final Map<String, String> params;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schemaRef = component.schemaRef;

    if (schemaRef == null) {
      return AppCard(
        title: component.ui?.label ?? 'Form',
        body: const AppErrorWidget(
          error: 'No schema reference provided for form',
        ),
      );
    }

    // Load schema from provider
    final schemaAsync = ref.watch(schemaProvider(schemaRef));

    return schemaAsync.when(
      data: (schema) => _FormContent(
        schema: schema,
        component: component,
        params: params,
      ),
      loading: () => const AppLoadingIndicator(
        message: 'Loading form...',
      ),
      error: (error, stack) => AppErrorWidget(
        error: error,
        onRetry: () => ref.invalidate(schemaProvider(schemaRef)),
      ),
    );
  }
}

/// Form content with loaded schema
class _FormContent extends StatelessWidget {
  const _FormContent({
    required this.schema,
    required this.component,
    required this.params,
  });

  final Schema schema;
  final ComponentDescriptor component;
  final Map<String, String> params;

  @override
  Widget build(BuildContext context) {
    // Determine form mode from component config
    final modeString = component.config['mode'] as String? ?? 'create';
    final mode = _parseFormMode(modeString);

    // Get initial data from params or config
    final initialData = component.config['initialData'] as Map<String, dynamic>?;

    return DynamicForm(
      schema: schema,
      mode: mode,
      initialData: initialData,
      onSubmit: (data) async {
        // TODO: Submit to BFF endpoint
        // For now, just log and show success
        await _handleSubmit(context, data);
      },
      submitButtonText: component.config['submitText'] as String?,
    );
  }

  FormMode _parseFormMode(String mode) {
    switch (mode.toLowerCase()) {
      case 'create':
        return FormMode.create;
      case 'edit':
        return FormMode.edit;
      case 'view':
        return FormMode.view;
      default:
        return FormMode.create;
    }
  }

  Future<void> _handleSubmit(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    // TODO: Implement actual submission to BFF
    // This would use the bffClient to POST/PUT data

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Log the data (in production this would be sent to BFF)
    debugPrint('Form submitted: $data');
    debugPrint('Resource: ${component.resource}');
  }
}
