import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/helpers/api_error_message.dart';
import 'package:taal/core/widgets/buttons/custom_button.dart';
import 'package:taal/core/widgets/otp/otp_field.dart';

typedef PhoneOtpSender = Future<({String? debugOtp, String? error})> Function(
  String phone,
);

class PhoneOtpVerificationSection extends StatefulWidget {
  const PhoneOtpVerificationSection({
    super.key,
    required this.phone,
    required this.otpController,
    required this.otpFocusNode,
    required this.onSendOtp,
    this.autoSendOnMount = false,
  });

  final String phone;
  final TextEditingController otpController;
  final FocusNode otpFocusNode;
  final PhoneOtpSender onSendOtp;
  final bool autoSendOnMount;

  @override
  State<PhoneOtpVerificationSection> createState() =>
      _PhoneOtpVerificationSectionState();
}

class _PhoneOtpVerificationSectionState
    extends State<PhoneOtpVerificationSection> {
  bool _sending = false;
  bool _sent = false;
  String? _inlineOtp;
  int _cooldown = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.autoSendOnMount && widget.phone.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _sendOtp());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => _cooldown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_cooldown <= 1) {
        timer.cancel();
        setState(() => _cooldown = 0);
        return;
      }
      setState(() => _cooldown -= 1);
    });
  }

  Future<void> _sendOtp() async {
    if (_sending || _cooldown > 0) return;
    setState(() {
      _sending = true;
      _inlineOtp = null;
    });

    final result = await widget.onSendOtp(widget.phone.trim());
    if (!mounted) return;

    setState(() => _sending = false);

    if (result.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ApiErrorMessage.from(result.error!))),
      );
      return;
    }

    setState(() {
      _sent = true;
      _inlineOtp = result.debugOtp;
    });
    _startCooldown();
    widget.otpFocusNode.requestFocus();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppStrings.otpSent.tr())),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppStrings.guestHelpVerifyStepHint.tr(),
          style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade700),
        ),
        12.height,
        if (_inlineOtp != null && _inlineOtp!.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: REdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Text(
              '${AppStrings.guestOtpInlineHint.tr()}: $_inlineOtp',
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
            ),
          ),
          12.height,
        ],
        CustomOTPField(
          controller: widget.otpController,
          focusNode: widget.otpFocusNode,
          onCompleted: (_) {},
          onChanged: (_) {},
        ),
        8.height,
        Text(
          AppStrings.guestOtpResendHint.tr(),
          style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
        ),
        12.height,
        CustomButton.outlined(
          text: _cooldown > 0
              ? '${AppStrings.resendOtp.tr()} (${_cooldown}s)'
              : (_sent ? AppStrings.resendOtp.tr() : AppStrings.sendOtp.tr()),
          onTap: (_sending || _cooldown > 0) ? null : _sendOtp,
        ),
        if (_sending)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
      ],
    );
  }
}
