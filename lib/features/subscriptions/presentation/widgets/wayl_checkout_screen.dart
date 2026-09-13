import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/widgets/appbar/logo_skip_appbar.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens Wayl checkout in an in-app browser tab (Custom Tabs / Safari VC).
/// Wayl blocks embedded WebViews via CSP (`frame-ancestors`), so a full browser
/// surface is required for payment methods to load.
class WaylCheckoutScreen extends StatefulWidget {
  const WaylCheckoutScreen({
    super.key,
    required this.paymentUrl,
    required this.referenceId,
    required this.checkPaid,
  });

  final String paymentUrl;
  final String referenceId;
  final Future<bool> Function(String referenceId) checkPaid;

  static Future<bool> open(
    BuildContext context, {
    required String paymentUrl,
    required String referenceId,
    required Future<bool> Function(String referenceId) checkPaid,
  }) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        fullscreenDialog: true,
        builder: (_) => WaylCheckoutScreen(
          paymentUrl: paymentUrl,
          referenceId: referenceId,
          checkPaid: checkPaid,
        ),
      ),
    );
    return result ?? false;
  }

  @override
  State<WaylCheckoutScreen> createState() => _WaylCheckoutScreenState();
}

class _WaylCheckoutScreenState extends State<WaylCheckoutScreen> {
  Timer? _pollTimer;
  var _closed = false;
  var _checkingPayment = false;
  var _browserOpen = false;
  var _browserFailed = false;

  @override
  void initState() {
    super.initState();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      unawaited(_verifyPaymentAndClose());
    });
    unawaited(_openCheckout());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _openCheckout() async {
    final uri = Uri.tryParse(widget.paymentUrl.trim());
    if (uri == null || !await canLaunchUrl(uri)) {
      if (mounted) {
        setState(() => _browserFailed = true);
      }
      return;
    }

    if (mounted) {
      setState(() => _browserOpen = true);
    }

    try {
      await launchUrl(
        uri,
        mode: LaunchMode.inAppBrowserView,
        webViewConfiguration: const WebViewConfiguration(
          enableJavaScript: true,
        ),
      );
    } catch (_) {
      if (mounted) {
        setState(() => _browserFailed = true);
      }
      return;
    } finally {
      if (mounted) {
        setState(() => _browserOpen = false);
      }
    }

    if (!_closed) {
      await _verifyPaymentAndClose();
    }
  }

  Future<void> _verifyPaymentAndClose() async {
    if (_closed || _checkingPayment || !mounted) {
      return;
    }

    _checkingPayment = true;
    try {
      final paid = await widget.checkPaid(widget.referenceId);
      if (!mounted || _closed || !paid) {
        return;
      }
      _close(success: true);
    } finally {
      _checkingPayment = false;
    }
  }

  void _close({required bool success}) {
    if (_closed || !mounted) {
      return;
    }
    _closed = true;
    Navigator.of(context).pop(success);
  }

  Future<void> _retryOpenCheckout() async {
    setState(() => _browserFailed = false);
    await _openCheckout();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _closed = true;
        }
      },
      child: Scaffold(
        appBar: CustomAppBar.backAppBar(
          title: AppStrings.choosePaymentMethod.tr(),
          centerTitle: true,
          onBackPressed: () => _close(success: false),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.payments_outlined,
                size: 72.sp,
                color: AppColors.primaryColor,
              ),
              24.height,
              Text(
                _browserFailed
                    ? AppStrings.paymentBrowserFailed.tr()
                    : _browserOpen
                        ? AppStrings.completePaymentInBrowser.tr()
                        : AppStrings.openingPaymentPage.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              12.height,
              Text(
                AppStrings.waitingForPayment.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade700,
                ),
              ),
              32.height,
              if (_browserFailed) ...[
                FilledButton(
                  onPressed: _retryOpenCheckout,
                  child: Text(AppStrings.retryPayment.tr()),
                ),
                12.height,
              ] else
                const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
