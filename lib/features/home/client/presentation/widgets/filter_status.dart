import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:taal/core/extensions/lang_extensions.dart';

import '../../../../../core/app_config/app_colors.dart';
import '../../../../../core/app_config/app_strings.dart';

enum StatusType {
  active(title: AppStrings.active, id: 1,),
  inactive(title: AppStrings.inactive, id: 2);
  final int id;
  final String title;
 const StatusType({required this.id, required this.title,});

}
class StatusSelectableChips extends StatefulWidget {
  final List<StatusType> options;
  final StatusType? selected;
  final String? title;
  final Function(StatusType?) onSelectionChanged;
  const StatusSelectableChips({
    super.key,
    required this.options,
    required this.selected,
    required this.title,
    required this.onSelectionChanged,
  });

  @override
  State<StatusSelectableChips> createState() => _StatusSelectableChipsState();
}

class _StatusSelectableChipsState extends State<StatusSelectableChips> {

  @override
  void initState() {
    super.initState();

  }


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.title ?? '',
          style:Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 4,
          children: widget.options.map((option) {
            final isSelected = option == widget.selected;
            return GestureDetector(
              onTap: () {
                widget.onSelectionChanged(option);
              },
              child: AnimatedContainer(
                width:widget.options.length <= 2 ? 155.w: 100.w,
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(
                  vertical: 17,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryColor : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                    isSelected ? Colors.transparent : AppColors.primaryColor,
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                  option.title.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isSelected ? AppColors.blackText : AppColors.primaryColor,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
