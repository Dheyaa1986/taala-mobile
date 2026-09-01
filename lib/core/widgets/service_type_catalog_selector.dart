import 'package:flutter/material.dart';
import 'package:taal/core/widgets/service_type_catalog_sections.dart';
import 'package:taal/features/home/client/data/model/service_provider_model/service_category_catalog_model.dart';

/// Backward-compatible alias: catalog picker using stacked section boxes.
class ServiceTypeCatalogSelector extends StatelessWidget {
  const ServiceTypeCatalogSelector({
    super.key,
    required this.categories,
    required this.selectedIds,
    required this.onChanged,
    this.multiSelect = true,
  });

  final List<ServiceCategoryCatalogModel> categories;
  final Set<String> selectedIds;
  final void Function(Set<String> selectedIds) onChanged;
  final bool multiSelect;

  @override
  Widget build(BuildContext context) {
    return ServiceTypeCatalogSections(
      categories: categories,
      selectedIds: selectedIds,
      onChanged: onChanged,
      multiSelect: multiSelect,
    );
  }
}
