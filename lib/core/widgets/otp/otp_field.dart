import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';
import 'package:taal/core/extensions/space_extension.dart';

import '../../app_config/app_colors.dart';
import '../../validations/validators.dart';

class CustomOTPField extends StatefulWidget {
  const CustomOTPField(
      {super.key,
      required this.controller,
      required this.focusNode,
      required this.onCompleted,
      required this.onChanged});
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String?) onCompleted;
  final Function(String?) onChanged;
  @override
  State<CustomOTPField> createState() => _CustomOTPFieldState();
}

class _CustomOTPFieldState extends State<CustomOTPField> {
  late PinTheme defaultPinTheme;
  @override
  void initState() {
    widget.focusNode.requestFocus();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    defaultPinTheme = PinTheme(
      width: 56.w,
      height: 56.w,
      textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: AppColors.primaryColor,
            fontSize: 20.sp,
          ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: Theme.of(context).hintColor),
      ),
    );
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Pinput(
        length: 4,
        controller: widget.controller,
        focusNode: widget.focusNode,
        defaultPinTheme: defaultPinTheme,
        separatorBuilder: (index) => 10.width,
        validator: CustomValidators.validateEmpty,
        hapticFeedbackType: HapticFeedbackType.lightImpact,
        onCompleted: widget.onCompleted,
        onChanged: widget.onChanged,
        cursor: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 22.w,
              height: 1,
              color: AppColors.primaryColor,
            ),
          ],
        ),
        focusedPinTheme: defaultPinTheme.copyBorderWith(
          border:  Border.all(color: Theme.of(context).primaryColor),
        ),
        submittedPinTheme: defaultPinTheme,
        errorPinTheme: defaultPinTheme.copyBorderWith(
          border:  Border.all(color: AppColors.errorColor),
        ),
      ),
    );
  }
}
