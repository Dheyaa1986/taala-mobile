import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app_config/app_colors.dart';
import '../../app_config/font_styles.dart';

class CustomDropDownField<T> extends StatefulWidget {
  final T? value;
  final List<DropdownMenuItem<T>>? items;
  final String label, hint;
  final void Function(dynamic)? onChanged;
  final Widget? prefix, suffix, icon;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final String? Function(T?)? validator;
  final double borderRadius;
  final bool bottomValidation;
  final TextStyle? textStyle, labelStyle, hintStyle;
  final Color? fillColor;

  const CustomDropDownField({
    super.key,
    required this.label,
    required this.hint,
    this.bottomValidation = false,
    this.prefix,
    this.suffix,
    this.validator,
    this.onTap,
    this.borderRadius = 8,
    this.textStyle,
    this.onChanged,
    this.padding,
    this.items,
    this.icon,
    this.value,
    this.labelStyle,
    this.hintStyle,
    this.fillColor,
  });

  @override
  State<CustomDropDownField> createState() => _CustomTextFieldState<T>();
}

class _CustomTextFieldState<T> extends State<CustomDropDownField> {
  String _validationMessage = '';
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (widget.label.isNotEmpty)
              Text.rich(
                TextSpan(
                  text: widget.label,
                  children: [
                    if (_validationMessage.isNotEmpty)
                      const TextSpan(
                        text: '*',
                        style: TextStyle(
                          color: AppColors.errorColor,
                        ),
                      )
                  ],
                ),
                style: widget.labelStyle ??
                    Theme.of(context).textTheme.labelMedium,
              ),
            if (_validationMessage.isNotEmpty && !widget.bottomValidation)
              Expanded(
                child: Text(
                  _validationMessage,
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.errorColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(
          height: 8.h,
        ),
        DropdownButtonFormField<T>(
          value: widget.value,
          items: List.from(widget.items ?? []),
          isExpanded: true,
          onChanged: (T? value) {
            widget.onChanged?.call(value);
          },
          onTap: widget.onTap,
          icon: widget.icon ?? const Icon(Icons.keyboard_arrow_down),
          isDense: true,
          validator: (text) {
            String? value = widget.validator?.call(text);
            setState(() {
              _validationMessage = value ?? '';
            });
            if (widget.bottomValidation) return value;
            return value != null ? '' : null;
          },
          style: widget.textStyle ?? Theme.of(context).textTheme.headlineSmall,
          hint: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              widget.hint,
              style: widget.hintStyle ?? FontStyles.textStyle14,
            ),
          ),
          dropdownColor: Theme.of(context).colorScheme.surface,
          decoration: InputDecoration(
            alignLabelWithHint: true,
            errorStyle: TextStyle(
              color: AppColors.errorColor,
              fontSize: 12.sp,
              fontWeight: FontWeight.w300,
            ),
            hintStyle: TextStyle(
              fontSize: 14.sp,
              color: AppColors.hintColor,
              fontWeight: FontWeight.w300,
            ),
            filled: true,
            fillColor: widget.fillColor ?? AppColors.textFieldFillColor,
            enabledBorder: fieldBorder,
            border: fieldBorder,
            focusedErrorBorder: fieldErrorBorder,
            errorBorder: fieldErrorBorder,
            focusedBorder: fieldBorder,
            prefixIcon: widget.prefix,
            suffixIcon: widget.suffix,
          ),
        ),
      ],
    );
  }

  InputBorder get fieldBorder => OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: const BorderSide(
          color: Colors.transparent,
          width: 1,
        ),
      );
  InputBorder get fieldErrorBorder => OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: const BorderSide(
          color: AppColors.errorColor,
          width: 1,
        ),
      );
}
