import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_colors.dart';
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
  });

  final List<ServiceCategoryCatalogModel> categories;
  final Set<String> selectedIds;
  final void Function(Set<String> selectedIds) onChanged;
  final bool multiSelect;

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
      return const Center(child: Text('لا توجد خدمات متاحة حالياً'));
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
    return Container(
      width: double.infinity,
      padding: REdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.textFieldFillColor.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.brandBorder, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            category.name ?? category.code ?? '',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.lightMainText,
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
