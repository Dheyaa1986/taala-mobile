import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/app_config/app_urls.dart';
import 'package:taal/features/home/client/data/model/service_provider_model/service_type_model.dart';

class ServiceTypeSelectorGrid extends StatelessWidget {
  const ServiceTypeSelectorGrid({
    super.key,
    required this.items,
    required this.selectedIds,
    required this.onChanged,
    this.multiSelect = true,
  });

  final List<ServiceTypeModel> items;
  final Set<String> selectedIds;
  final void Function(Set<String> selectedIds) onChanged;
  final bool multiSelect;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(child: Text(AppStrings.noServiceTypesAvailable.tr()));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10.h,
        crossAxisSpacing: 10.w,
        childAspectRatio: 0.78,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final id = item.id ?? '';
        final enabled = item.isEnabled;
        final selected = enabled && selectedIds.contains(id);
        final imageUrl = item.image != null && item.image!.isNotEmpty
            ? (item.image!.startsWith('http')
                ? item.image!
                : AppUrls.imageLink(item.image!))
            : null;

        return GestureDetector(
          onTap: enabled
              ? () {
                  final next = Set<String>.from(selectedIds);
                  if (multiSelect) {
                    if (selected) {
                      next.remove(id);
                    } else {
                      next.add(id);
                    }
                  } else {
                    next
                      ..clear()
                      ..add(id);
                  }
                  onChanged(next);
                }
              : null,
          child: Opacity(
            opacity: enabled ? 1 : 0.55,
            child: Container(
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primaryColor.withValues(alpha: 0.12)
                    : AppColors.textFieldFillColor,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: selected
                      ? AppColors.primaryColor
                      : AppColors.brandBorder,
                  width: selected ? 2 : 1,
                ),
              ),
              padding: REdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (imageUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: enabled
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              width: 42.w,
                              height: 42.w,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => Icon(
                                Icons.home_repair_service_outlined,
                                size: 36.sp,
                                color: AppColors.primaryColor,
                              ),
                            )
                          : ColorFiltered(
                              colorFilter: ColorFilter.matrix(<double>[
                                0.2126, 0.7152, 0.0722, 0, 0,
                                0.2126, 0.7152, 0.0722, 0, 0,
                                0.2126, 0.7152, 0.0722, 0, 0,
                                0, 0, 0, 0.45, 0,
                              ]),
                              child: CachedNetworkImage(
                                imageUrl: imageUrl,
                                width: 42.w,
                                height: 42.w,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => Icon(
                                  Icons.home_repair_service_outlined,
                                  size: 36.sp,
                                  color: AppColors.commentColor,
                                ),
                              ),
                            ),
                    )
                  else
                    Icon(
                      Icons.home_repair_service_outlined,
                      size: 36.sp,
                      color: enabled
                          ? AppColors.primaryColor
                          : AppColors.commentColor,
                    ),
                  4.height,
                  Text(
                    item.name ?? '',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: enabled
                          ? AppColors.lightMainText
                          : AppColors.commentColor,
                    ),
                  ),
                  2.height,
                  Text(
                    enabled
                        ? AppStrings.serviceAvailable.tr()
                        : AppStrings.serviceComingSoon.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: enabled
                          ? AppColors.primaryColor
                          : AppColors.commentColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
