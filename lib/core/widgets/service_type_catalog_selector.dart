import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/widgets/service_type_selector_grid.dart';
import 'package:taal/features/home/client/data/model/service_provider_model/service_category_catalog_model.dart';

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
    if (categories.isEmpty) {
      return const Center(child: Text('لا توجد خدمات متاحة حالياً'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final category in categories) ...[
          if ((category.name ?? '').isNotEmpty) ...[
            Text(
              category.name!,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.lightMainText,
              ),
            ),
            8.height,
          ],
          ServiceTypeSelectorGrid(
            items: category.serviceTypes,
            selectedIds: selectedIds,
            onChanged: onChanged,
            multiSelect: multiSelect,
          ),
          16.height,
        ],
      ],
    );
  }
}
