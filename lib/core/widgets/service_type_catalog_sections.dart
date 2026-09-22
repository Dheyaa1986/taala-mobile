import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/design_system/theme/taala_tokens.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/widgets/service_type_selector_grid.dart';
import 'package:taal/features/home/client/data/model/service_provider_model/service_category_catalog_model.dart';

/// Shows each service category in its own bordered box with a title and type grid.
class ServiceTypeCatalogSections extends StatelessWidget {
  const ServiceTypeCatalogSections({
    super.key,
    required this.categories,
    required this.selectedIds,
    required this.onChanged,
    this.multiSelect = true,
    this.isLoadError = false,
  });

  final List<ServiceCategoryCatalogModel> categories;
  final Set<String> selectedIds;
  final void Function(Set<String> selectedIds) onChanged;
  final bool multiSelect;
  final bool isLoadError;

  static const _codeOrder = ['CRANE', 'OTHER'];

  int _categorySortIndex(ServiceCategoryCatalogModel category) {
    final code = category.code?.toUpperCase();
    final index = code == null ? -1 : _codeOrder.indexOf(code);
    if (index >= 0) return index;
    return 50 + category.sortOrder;
  }

  List<ServiceCategoryCatalogModel> get _visibleCategories {
    final visible =
        categories.where((c) => c.serviceTypes.isNotEmpty).toList();
    visible.sort((a, b) {
      final byOrder = _categorySortIndex(a).compareTo(_categorySortIndex(b));
      if (byOrder != 0) return byOrder;
      return (a.name ?? a.code ?? '').compareTo(b.name ?? b.code ?? '');
    });
    return visible;
  }

  @override
  Widget build(BuildContext context) {
    final sections = _visibleCategories;
    if (sections.isEmpty) {
      if (isLoadError) return const SizedBox.shrink();
      return Center(
        child: Text(AppStrings.noServiceTypesAvailable.tr()),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < sections.length; i++) ...[
          if (i > 0) 16.height,
          _CategorySectionBox(
            category: sections[i],
            selectedIds: selectedIds,
            onChanged: onChanged,
            multiSelect: multiSelect,
          ),
        ],
      ],
    );
  }
}

class _CategorySectionBox extends StatelessWidget {
  const _CategorySectionBox({
    required this.category,
    required this.selectedIds,
    required this.onChanged,
    required this.multiSelect,
  });

  final ServiceCategoryCatalogModel category;
  final Set<String> selectedIds;
  final void Function(Set<String> selectedIds) onChanged;
  final bool multiSelect;

  @override
  Widget build(BuildContext context) {
    final tokens = TaalaTokens.of(context);

    return Container(
      width: double.infinity,
      padding: REdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tokens.surfaceMuted,
        borderRadius: BorderRadius.circular(tokens.cardRadius),
        border: Border.all(color: tokens.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            category.name ?? category.code ?? '',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: tokens.textPrimary,
                ),
          ),
          12.height,
          ServiceTypeSelectorGrid(
            items: category.serviceTypes,
            selectedIds: selectedIds,
            onChanged: onChanged,
            multiSelect: multiSelect,
          ),
        ],
      ),
    );
  }
}
