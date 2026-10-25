import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/auth/firebase_phone_otp.dart';
import 'package:taal/core/custom_launcher/custom_launcher.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/helpers/api_error_message.dart';
import 'package:taal/design_system/components/taala_button.dart';
import 'package:taal/design_system/theme/taala_tokens.dart';
import 'package:taal/core/widgets/otp/otp_field.dart';
import 'package:taal/features/app_info/data/repository/app_public_info_repository.dart';

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
    this.onFirebaseIdToken,
  });

  final String phone;
  final TextEditingController otpController;
  final FocusNode otpFocusNode;
  final PhoneOtpSender onSendOtp;
  final bool autoSendOnMount;
  final ValueChanged<String>? onFirebaseIdToken;

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
  bool _whatsAppSession = false;
  bool _firebaseChannel = false;
  bool _confirmingFirebase = false;
  String? _whatsAppNumber;
  String _whatsAppMessage = 'تأكيد طلة';
  final _firebaseOtp = FirebasePhoneOtpClient();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    await _loadOtpChannel();
    if (widget.autoSendOnMount && widget.phone.trim().isNotEmpty) {
      await _sendOtp();
    }
  }

  Future<void> _loadOtpChannel() async {
    if (!getIt.isRegistered<AppPublicInfoRepository>()) {
      return;
    }
    final result = await getIt<AppPublicInfoRepository>().getPublicInfo();
    if (!mounted) return;
    result.fold((_) {}, (info) {
      setState(() {
        _whatsAppSession = info.usesWhatsAppSessionOtp;
        _firebaseChannel = info.usesFirebaseOtp;
        _whatsAppNumber = info.otpWhatsAppNumber;
        if (info.otpWhatsAppMessage.trim().isNotEmpty) {
          _whatsAppMessage = info.otpWhatsAppMessage.trim();
        }
      });
    });
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

    if (_firebaseChannel) {
      try {
        await _firebaseOtp.sendSms(widget.phone.trim());
      } catch (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ApiErrorMessage.from(error.toString()))),
        );
        return;
      }
      if (!mounted) return;
    }

    setState(() {
      _sent = true;
      _inlineOtp = (_whatsAppSession || _firebaseChannel) ? null : result.debugOtp;
    });
    _startCooldown();
    widget.otpFocusNode.requestFocus();

    if (_whatsAppSession &&
        _whatsAppNumber != null &&
        _whatsAppNumber!.trim().isNotEmpty) {
      await getIt<CustomLauncher>().openWhatsApp(
        _whatsAppNumber!,
        message: _whatsAppMessage,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.otpWhatsAppOpened.tr())),
      );
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppStrings.otpSent.tr())),
    );
  }

  Future<void> _confirmFirebaseIfNeeded(String smsCode) async {
    if (!_firebaseChannel || widget.onFirebaseIdToken == null) {
      return;
    }
    if (_confirmingFirebase || smsCode.trim().length < 6) {
      return;
    }
    setState(() => _confirmingFirebase = true);
    try {
      final token = await _firebaseOtp.confirmSms(smsCode);
      if (!mounted) return;
      widget.onFirebaseIdToken!(token);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ApiErrorMessage.from(error.toString()))),
      );
    } finally {
      if (mounted) {
        setState(() => _confirmingFirebase = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = TaalaTokens.of(context);
    final hint = _whatsAppSession
        ? AppStrings.guestHelpVerifyWhatsAppHint.tr()
        : AppStrings.guestHelpVerifyStepHint.tr();
    final resendHint = _whatsAppSession
        ? AppStrings.guestOtpWhatsAppResendHint.tr()
        : AppStrings.guestOtpResendHint.tr();
    final idleLabel = _whatsAppSession
        ? AppStrings.openWhatsAppForOtp.tr()
        : AppStrings.sendOtp.tr();
    final sentLabel = _whatsAppSession
        ? AppStrings.resendOtpWhatsApp.tr()
        : AppStrings.resendOtp.tr();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          hint,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: tokens.textSecondary,
              ),
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
          onCompleted: (value) {
            if (value != null) {
              unawaited(_confirmFirebaseIfNeeded(value));
            }
          },
          onChanged: (_) {},
        ),
        8.height,
        Text(
          resendHint,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: tokens.textSecondary,
              ),
        ),
        12.height,
        TaalaButton(
          label: _cooldown > 0
              ? '$sentLabel (${_cooldown}s)'
              : (_sent ? sentLabel : idleLabel),
          variant: TaalaButtonVariant.secondary,
          onPressed: (_sending || _cooldown > 0) ? null : _sendOtp,
        ),
        if (_sending || _confirmingFirebase)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
      ],
    );
  }
}
