/// Data table renderer with dynamic table engine.
///
/// Loads data from BFF and renders using DynamicTable.
library;

import 'package:flutter/material.dart';

import '../../../core/core.dart';
import '../../../tables/tables.dart';
import '../../../widgets/shared/shared.dart';

/// Renders data table component with full functionality
class DataTableRenderer extends StatefulWidget {
  const DataTableRenderer({
    required this.component,
    this.params = const {},
    super.key,
  });

  final ComponentDescriptor component;
  final Map<String, String> params;

  @override
  State<DataTableRenderer> createState() => _DataTableRendererState();
}

class _DataTableRendererState extends State<DataTableRenderer> {
  late TableController _controller;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    // Parse table config
    final DataTableConfig tableConfig;
    if (widget.component.config['table'] != null) {
      try {
        tableConfig = DataTableConfig.fromJson(
          widget.component.config['table'] as Map<String, dynamic>,
        );
      } catch (e) {
        // Use default config if parsing fails
        tableConfig = DataTableConfig(
          columns: [
            TableColumn(field: 'id', label: 'ID'),
          ],
        );
      }
    } else {
      // Use default config
      tableConfig = DataTableConfig(
        columns: [
          TableColumn(field: 'id', label: 'ID'),
        ],
      );
    }

    _controller = TableController(
      tableConfig: tableConfig,
      fetchData: _fetchTableData,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<TableDataResponse> _fetchTableData(TableDataRequest request) async {
    // TODO: Implement actual BFF data fetching
    // For now, return mock data

    await Future.delayed(const Duration(milliseconds: 500));

    // Generate mock data based on columns
    final mockRows = List.generate(
      request.pageSize,
      (index) {
        final row = <String, dynamic>{};
        row['id'] = (request.page * request.pageSize + index + 1).toString();

        for (final column in _controller.tableConfig.columns) {
          if (column.field != 'id') {
            row[column.field] = 'Sample ${column.field} ${index + 1}';
          }
        }

        return row;
      },
    );

    return TableDataResponse(
      rows: mockRows,
      totalCount: 100, // Mock total
    );
  }

  @override
  Widget build(BuildContext context) {
    return DynamicTable(
      controller: _controller,
      onRowTap: (row) {
        // TODO: Handle row tap (navigate to detail page)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Row tapped: ${row['id']}')),
        );
      },
      onRowAction: (action, row) {
        // TODO: Execute row action
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${action.label} on row ${row['id']}'),
          ),
        );
      },
      onBulkAction: (action, rowIds) {
        // TODO: Execute bulk action
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${action.label} on ${rowIds.length} rows'),
          ),
        );
      },
    );
  }
}
