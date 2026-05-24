import 'package:flutter/material.dart';
import 'package:taal/core/extensions/lang_extensions.dart';

import '../../app_config/app_colors.dart';

class CustomSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const CustomSwitch({super.key, required this.value, required this.onChanged});

  @override
  _CustomSwitchState createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onChanged(!widget.value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 50,
        height: 25,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: !widget.value
              ? Colors.grey.shade300
              : AppColors.primaryColor, // Background color
        ),
        padding: const EdgeInsets.symmetric(horizontal: 3),
        alignment: widget.value
            ? context.isArabic
                ? Alignment.centerLeft
                : Alignment.centerRight
            : context.isArabic
                ? Alignment.centerRight
                : Alignment.centerLeft,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white, // Thumb color
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 3,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
