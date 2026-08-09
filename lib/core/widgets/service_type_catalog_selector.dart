import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/widgets/service_type_selector_grid.dart';
import 'package:taal/features/home/client/data/model/service_provider_model/service_category_catalog_model.dart';

class ServiceTypeCatalogSelector extends StatefulWidget {
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
  State<ServiceTypeCatalogSelector> createState() =>
      _ServiceTypeCatalogSelectorState();
}

class _ServiceTypeCatalogSelectorState extends State<ServiceTypeCatalogSelector> {
  int _categoryIndex = 0;

  List<ServiceCategoryCatalogModel> get _visibleCategories =>
      widget.categories.where((c) => c.serviceTypes.isNotEmpty).toList();

  @override
  void didUpdateWidget(covariant ServiceTypeCatalogSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    final count = _visibleCategories.length;
    if (count == 0) {
      _categoryIndex = 0;
    } else if (_categoryIndex >= count) {
      _categoryIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = _visibleCategories;
    if (categories.isEmpty) {
      return const Center(child: Text('لا توجد خدمات متاحة حالياً'));
    }

    final index = _categoryIndex.clamp(0, categories.length - 1);
    final active = categories[index];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: List.generate(categories.length, (i) {
            final category = categories[i];
            final selected = i == index;
            return Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.only(
                  end: i < categories.length - 1 ? 8.w : 0,
                ),
                child: Material(
                  color: selected
                      ? AppColors.primaryColor.withValues(alpha: 0.12)
                      : AppColors.textFieldFillColor,
                  borderRadius: BorderRadius.circular(12.r),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12.r),
                    onTap: () => setState(() => _categoryIndex = i),
                    child: Container(
                      padding: REdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: selected
                              ? AppColors.primaryColor
                              : AppColors.brandBorder,
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        category.name ?? category.code ?? '',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w600,
                          color: AppColors.lightMainText,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        16.height,
        Text(
          active.name ?? '',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.lightMainText,
          ),
        ),
        8.height,
        ServiceTypeSelectorGrid(
          items: active.serviceTypes,
          selectedIds: widget.selectedIds,
          onChanged: widget.onChanged,
          multiSelect: widget.multiSelect,
        ),
      ],
    );
  }
}
