import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app_config/app_colors.dart';
import '../../app_config/font_styles.dart';

class CustomTextField extends StatefulWidget {
  final String hint;
  final String? label;
  final TextEditingController? controller;
  final bool obscure, readOnly, enabled;
  final bool? filled;
  final TextInputType? keyboardType;
  final Widget? prefix, suffix;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final int? minLines, maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final TextStyle? textStyle, labelStyle;
  final Function(String)? onChanged;
  final double? borderRadius;
  const CustomTextField(
      {super.key,
      this.label,
      required this.hint,
      this.controller,
      this.obscure = false,
      this.readOnly = false,
      this.keyboardType,
      this.prefix,
      this.suffix,
      this.validator,
      this.filled = true,
      this.onTap,
      this.minLines,
      this.maxLines,
      this.inputFormatters,
      this.textStyle,
      this.onChanged,
      this.labelStyle,
      this.borderRadius,
      this.enabled = true});

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _hasText = false;
  String _validationMessage = '';
  @override
  void initState() {
    widget.controller?.addListener(() {
      if (!mounted) return;
      setState(() {
        _hasText = widget.controller?.text.isNotEmpty == true;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (widget.label != null) ...[
              if (widget.label!.isNotEmpty) ...[
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
                      Theme.of(context).textTheme.labelMedium!.copyWith(
                        fontWeight:  FontWeight.w500,
                      ),
                ),
              ],
            ],
            if (widget.label != null) ...[
              if (_validationMessage.isNotEmpty)
                Expanded(
                  child: Text(
                    _validationMessage,
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    style: FontStyles.textStyle12.copyWith(
                      color: AppColors.errorColor,
                    ),
                  ),
                ),
            ],
          ],
        ),
        SizedBox(
          height: 6.h,
        ),
        TextFormField(
          enabled: widget.enabled,
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
          onChanged: widget.onChanged,
          onTap: widget.onTap,
          readOnly: widget.readOnly,
          controller: widget.controller,
          obscureText: widget.obscure,
          keyboardType: widget.keyboardType,
          minLines: widget.minLines,
          maxLines: widget.maxLines ?? 1,
          inputFormatters: widget.inputFormatters,
          validator: (text) {
            String? value = widget.validator?.call(text);
            setState(() {
              _validationMessage = value ?? '';
            });
            return value != null ? '' : null;
          },
          style: widget.textStyle ?? Theme.of(context).textTheme.headlineSmall,
          decoration: InputDecoration(
            fillColor: AppColors.textFieldFillColor,
            filled: widget.filled,
            hintText: widget.hint,
            hintStyle: FontStyles.textStyle14,
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
        borderSide: BorderSide(
          color: _hasText ? AppColors.lightMainText : Colors.transparent,
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
