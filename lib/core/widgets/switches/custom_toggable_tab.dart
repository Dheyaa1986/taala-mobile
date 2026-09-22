import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/design_system/theme/taala_tokens.dart';

class CustomToggleTab extends StatelessWidget {
  final int selectedIndex;
  final List<String> titles;
  final ValueChanged<int> onTabChanged;

  const CustomToggleTab({
    super.key,
    required this.selectedIndex,
    required this.titles,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = TaalaTokens.of(context);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: tokens.primarySoft,
        borderRadius: BorderRadius.circular(24),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(titles.length, (index) {
            final isSelected = selectedIndex == index;
            return FittedBox(
              fit: BoxFit.scaleDown,
              child: GestureDetector(
                onTap: () => onTabChanged(index),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 23.5, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? tokens.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      titles[index],
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontSize: 14.sp,
                            color: isSelected
                                ? tokens.textPrimary
                                : tokens.textSecondary,
                          ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
