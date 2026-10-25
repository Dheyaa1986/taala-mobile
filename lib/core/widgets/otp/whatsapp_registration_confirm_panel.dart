import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/custom_launcher/custom_launcher.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/helpers/api_error_message.dart';
import 'package:taal/design_system/components/taala_button.dart';
import 'package:taal/features/guest/data/repository/guest_otp_repository.dart';

class WhatsAppRegistrationConfirmPanel extends StatefulWidget {
  const WhatsAppRegistrationConfirmPanel({
    super.key,
    required this.phone,
    required this.onBegin,
    required this.onConfirmed,
  });

  final String phone;
  final Future<GuestOtpSendResult?> Function(String phone) onBegin;
  final ValueChanged<String> onConfirmed;

  @override
  State<WhatsAppRegistrationConfirmPanel> createState() =>
      _WhatsAppRegistrationConfirmPanelState();
}

class _WhatsAppRegistrationConfirmPanelState
    extends State<WhatsAppRegistrationConfirmPanel> {
  final _otpRepository = GuestOtpRepository();
  Timer? _pollTimer;
  bool _starting = false;
  bool _waiting = false;
  bool _confirmed = false;
  String? _error;
  String? _waitToken;
  String _whatsAppNumber = '';
  String _message = 'أكد التسجيل';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _start() async {
    if (_starting) return;
    setState(() {
      _starting = true;
      _error = null;
    });

    try {
      final result = await widget.onBegin(widget.phone.trim());
      if (!mounted) return;
      if (result == null ||
          result.waitToken == null ||
          result.waitToken!.isEmpty) {
        setState(() {
          _starting = false;
          _error = AppStrings.whatsAppConfirmStartFailed.tr();
        });
        return;
      }

      setState(() {
        _starting = false;
        _waiting = true;
        _waitToken = result.waitToken;
        _whatsAppNumber = result.whatsappNumber?.trim() ?? '';
        if (result.whatsappMessage != null &&
            result.whatsappMessage!.trim().isNotEmpty) {
          _message = result.whatsappMessage!.trim();
        }
      });
      await _openWhatsApp();
      _startPolling();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _starting = false;
        _error = ApiErrorMessage.from(error.toString());
      });
    }
  }

  Future<void> _openWhatsApp() async {
    if (_whatsAppNumber.isEmpty) return;
    await getIt<CustomLauncher>().openWhatsApp(
      _whatsAppNumber,
      message: _message,
    );
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) => _poll());
  }

  Future<void> _poll() async {
    final waitToken = _waitToken;
    if (waitToken == null || _confirmed) return;

    final result = await _otpRepository.pollWhatsAppConfirm(
      phone: widget.phone,
      waitToken: waitToken,
    );
    if (!mounted) return;
    result.fold((_) {}, (status) {
      if (!status.isConfirmed) return;
      _pollTimer?.cancel();
      setState(() {
        _waiting = false;
        _confirmed = true;
      });
      widget.onConfirmed(status.confirmToken!.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEFEAE2),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFD1D7DB)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: const Color(0xFF075E54),
            padding: REdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              AppStrings.whatsAppConfirmTitle.tr(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Padding(
            padding: REdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppStrings.whatsAppConfirmHint.tr(),
                  style: TextStyle(
                    fontSize: 13.sp,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
                16.height,
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 240.w),
                    padding: REdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9FDD3),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      _message,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                16.height,
                if (_error != null)
                  Text(
                    _error!,
                    style: TextStyle(color: Colors.red.shade700, fontSize: 13.sp),
                  ),
                if (_confirmed)
                  Text(
                    AppStrings.whatsAppConfirmDone.tr(),
                    style: TextStyle(
                      color: const Color(0xFF075E54),
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                    ),
                  )
                else if (_waiting)
                  Row(
                    children: [
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      10.width,
                      Expanded(
                        child: Text(
                          AppStrings.whatsAppConfirmWaiting.tr(),
                          style: TextStyle(fontSize: 13.sp),
                        ),
                      ),
                    ],
                  ),
                16.height,
                TaalaButton(
                  label: AppStrings.whatsAppConfirmSend.tr(),
                  onPressed: _starting ? null : _openWhatsApp,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
