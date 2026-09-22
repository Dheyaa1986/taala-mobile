import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../design_system/theme/taala_tokens.dart';

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
  final String? helperText;
  final int? minLines, maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final TextStyle? textStyle, labelStyle;
  final Function(String)? onChanged;
  final double? borderRadius;
  final FocusNode? focusNode;
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
      this.helperText,
      this.filled = true,
      this.onTap,
      this.minLines,
      this.maxLines,
      this.inputFormatters,
      this.textStyle,
      this.onChanged,
      this.labelStyle,
      this.borderRadius,
      this.focusNode,
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
                        TextSpan(
                          text: '*',
                          style: TextStyle(
                            color: TaalaTokens.of(context).error,
                          ),
                        )
                    ],
                  ),
                  style: widget.labelStyle ??
                      Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: TaalaTokens.of(context).textPrimary,
                          ),
                ),
              ],
            ],
          ],
        ),
        SizedBox(
          height: 6.h,
        ),
        TextFormField(
          enabled: widget.enabled,
          focusNode: widget.focusNode,
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
          style: widget.textStyle ??
              Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: TaalaTokens.of(context).textPrimary,
                  ),
          decoration: InputDecoration(
            fillColor: TaalaTokens.of(context).surfaceMuted,
            filled: widget.filled ?? true,
            hintText: widget.hint,
            hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: TaalaTokens.of(context).textSecondary,
                ),
            enabledBorder: fieldBorder(context),
            border: fieldBorder(context),
            focusedErrorBorder: fieldErrorBorder(context),
            errorBorder: fieldErrorBorder(context),
            focusedBorder: focusedBorder(context),
            prefixIcon: widget.prefix,
            suffixIcon: widget.suffix,
          ),
        ),
        if (widget.helperText != null && widget.helperText!.isNotEmpty) ...[
          SizedBox(height: 6.h),
          Text(
            widget.helperText!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: TaalaTokens.of(context).textSecondary,
                ),
          ),
        ],
        if (_validationMessage.isNotEmpty) ...[
          SizedBox(height: 4.h),
          Text(
            _validationMessage,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: TaalaTokens.of(context).error,
                ),
          ),
        ],
      ],
    );
  }

  InputBorder fieldBorder(BuildContext context) {
    final tokens = TaalaTokens.of(context);
    final radius = widget.borderRadius ?? tokens.inputRadius;
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: tokens.borderSubtle),
    );
  }

  InputBorder focusedBorder(BuildContext context) {
    final tokens = TaalaTokens.of(context);
    final radius = widget.borderRadius ?? tokens.inputRadius;
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: tokens.primary, width: 1.5),
    );
  }

  InputBorder fieldErrorBorder(BuildContext context) {
    final tokens = TaalaTokens.of(context);
    final radius = widget.borderRadius ?? tokens.inputRadius;
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: tokens.error),
    );
  }
}
