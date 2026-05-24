import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app_config/app_colors.dart';

class CustomSelectionChip extends StatelessWidget {
  final String label, value;
  final bool isSelected;
  final ValueChanged<String>? onSelect;
  const CustomSelectionChip({
    super.key,
    required this.label,
    required this.value,
    required this.isSelected,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isSelected) return;
        onSelect?.call(value);
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          gradient: isSelected
              ? AppColors.primaryGradient
              : const LinearGradient(
                  colors: [Colors.transparent, Colors.transparent],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.borderColor,
          ),
        ),
        child: Center(
          child: FittedBox(
            child: AnimatedDefaultTextStyle(
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: isSelected ? Colors.white : AppColors.borderColor,
                  ),
              duration: Duration(milliseconds: 300),
              child: Text(label),
            ),
          ),
        ),
      ),
    );
  }
}
