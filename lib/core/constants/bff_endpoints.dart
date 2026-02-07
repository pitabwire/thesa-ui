/// BFF API endpoint constants.
///
/// All BFF endpoint paths are defined here for centralized management.
/// Base URL is configured separately per environment.
library;

/// BFF API endpoints
class BffEndpoints {
  BffEndpoints._(); // Private constructor to prevent instantiation

  /// Base path for UI endpoints
  static const String uiBase = '/ui';

  // Authentication and session
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String session = '/auth/session';

  // Capabilities and navigation
  static const String capabilities = '$uiBase/capabilities';
  static const String navigation = '$uiBase/navigation';

  // Pages
  static const String pages = '$uiBase/pages';
  static String page(String pageId) => '$pages/$pageId';

  // Schemas
  static const String schemas = '$uiBase/schemas';
  static String schema(String schemaId) => '$schemas/$schemaId';

  // Resources (generic CRUD operations)
  static const String resources = '$uiBase/resources';
  static String resource(String resourceType) => '$resources/$resourceType';
  static String resourceItem(String resourceType, String id) =>
      '$resources/$resourceType/$id';

  // Actions
  static const String actions = '$uiBase/actions';
  static String action(String actionId) => '$actions/$actionId';

  // Workflows
  static const String workflows = '$uiBase/workflows';
  static String workflow(String workflowId) => '$workflows/$workflowId';
  static String workflowStep(String workflowId, String stepId) =>
      '$workflows/$workflowId/steps/$stepId';

  // Search and filtering
  static String search(String resourceType) => '$resources/$resourceType/search';
  static String filter(String resourceType) => '$resources/$resourceType/filter';

  // File operations
  static const String upload = '$uiBase/upload';
  static const String download = '$uiBase/download';
  static String downloadFile(String fileId) => '$download/$fileId';
}
