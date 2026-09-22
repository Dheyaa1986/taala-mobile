import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../design_system/theme/taala_tokens.dart';

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
    final tokens = TaalaTokens.of(context);

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
                      TextSpan(
                        text: '*',
                        style: TextStyle(color: tokens.error),
                      ),
                  ],
                ),
                style: widget.labelStyle ??
                    Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: tokens.textPrimary,
                        ),
              ),
            if (_validationMessage.isNotEmpty && !widget.bottomValidation)
              Expanded(
                child: Text(
                  _validationMessage,
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: tokens.error,
                      ),
                ),
              ),
          ],
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<T>(
          value: widget.value,
          items: List.from(widget.items ?? []),
          isExpanded: true,
          onChanged: (T? value) {
            widget.onChanged?.call(value);
          },
          onTap: widget.onTap,
          icon: widget.icon ??
              Icon(Icons.keyboard_arrow_down, color: tokens.textSecondary),
          isDense: true,
          validator: (text) {
            String? value = widget.validator?.call(text);
            setState(() {
              _validationMessage = value ?? '';
            });
            if (widget.bottomValidation) return value;
            return value != null ? '' : null;
          },
          style: widget.textStyle ??
              Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: tokens.textPrimary,
                  ),
          hint: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              widget.hint,
              style: widget.hintStyle ??
                  Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: tokens.textSecondary,
                      ),
            ),
          ),
          dropdownColor: tokens.surface,
          decoration: InputDecoration(
            alignLabelWithHint: true,
            errorStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: tokens.error,
                ),
            hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: tokens.textSecondary,
                ),
            filled: true,
            fillColor: widget.fillColor ?? tokens.surfaceMuted,
            enabledBorder: _fieldBorder(tokens),
            border: _fieldBorder(tokens),
            focusedErrorBorder: _fieldErrorBorder(tokens),
            errorBorder: _fieldErrorBorder(tokens),
            focusedBorder: _focusedBorder(tokens),
            prefixIcon: widget.prefix,
            suffixIcon: widget.suffix,
          ),
        ),
      ],
    );
  }

  InputBorder _fieldBorder(TaalaTokens tokens) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius.r),
        borderSide: BorderSide(color: tokens.borderSubtle),
      );

  InputBorder _focusedBorder(TaalaTokens tokens) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius.r),
        borderSide: BorderSide(color: tokens.primary, width: 1.5),
      );

  InputBorder _fieldErrorBorder(TaalaTokens tokens) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius.r),
        borderSide: BorderSide(color: tokens.error),
      );
}
