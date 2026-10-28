import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/helpers/api_error_message.dart';
import 'package:taal/design_system/components/taala_button.dart';
import 'package:taal/design_system/theme/taala_tokens.dart';
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
    this.showIntroHint = true,
    this.onCompleted,
  });

  final String phone;
  final TextEditingController otpController;
  final FocusNode otpFocusNode;
  final PhoneOtpSender onSendOtp;
  final bool autoSendOnMount;
  final bool showIntroHint;
  final ValueChanged<String>? onCompleted;

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
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    if (widget.autoSendOnMount && widget.phone.trim().isNotEmpty) {
      await _sendOtp();
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

  bool _isRateLimited(String error) {
    final text = error.toLowerCase();
    return text.contains('كثير') ||
        text.contains('too many') ||
        text.contains('429') ||
        text.contains('rate') ||
        text.contains('انتظر دقيقة');
  }

  Future<void> _sendOtp() async {
    if (_sending || _cooldown > 0) return;
    setState(() {
      _sending = true;
      _inlineOtp = null;
    });

    final result = await widget.onSendOtp(widget.phone.trim());
    if (!mounted) return;

    if (result.error != null) {
      final limited = _isRateLimited(result.error!);
      setState(() {
        _sending = false;
        if (limited) {
          _sent = true;
        }
      });
      if (limited) {
        _startCooldown();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            limited
                ? AppStrings.otpWaitThenResend.tr()
                : ApiErrorMessage.from(result.error!),
          ),
        ),
      );
      return;
    }

    setState(() {
      _sending = false;
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
    final tokens = TaalaTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showIntroHint) ...[
          Text(
            AppStrings.guestHelpVerifyStepHint.tr(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: tokens.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          12.height,
        ],
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
          onCompleted: (value) {
            if (value != null && value.length == 6) {
              widget.onCompleted?.call(value);
            }
          },
          onChanged: (_) {},
        ),
        8.height,
        Text(
          _sending
              ? AppStrings.otpSendingWhatsApp.tr()
              : AppStrings.guestOtpResendHint.tr(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: tokens.textSecondary,
              ),
          textAlign: TextAlign.center,
        ),
        12.height,
        TaalaButton(
          label: _sending
              ? AppStrings.otpSendingWhatsApp.tr()
              : _cooldown > 0
                  ? '${AppStrings.resendOtp.tr()} (${_cooldown}s)'
                  : (_sent
                      ? AppStrings.resendOtp.tr()
                      : AppStrings.sendOtp.tr()),
          variant: TaalaButtonVariant.secondary,
          onPressed: (_sending || _cooldown > 0) ? null : _sendOtp,
        ),
      ],
    );
  }
}
