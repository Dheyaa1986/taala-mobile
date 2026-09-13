import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/widgets/appbar/logo_skip_appbar.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
  late final WebViewController _controller;
  Timer? _pollTimer;
  var _loading = true;
  var _checkingPayment = false;
  var _closed = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) {
              setState(() => _loading = true);
            }
          },
          onPageFinished: (_) {
            if (mounted) {
              setState(() => _loading = false);
            }
          },
          onUrlChange: (change) {
            final url = change.url;
            if (url != null) {
              _handleUrlChange(url);
            }
          },
          onNavigationRequest: (request) {
            _handleUrlChange(request.url);
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));

    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      unawaited(_verifyPaymentAndClose());
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  bool _isCheckoutHost(String host) {
    final normalized = host.toLowerCase();
    return normalized.startsWith('checkout.') ||
        normalized.startsWith('pay.') ||
        normalized == 'api.thewayl.com';
  }

  void _handleUrlChange(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return;
    }

    final host = uri.host.toLowerCase();
    if (!host.contains('thewayl.com') || _isCheckoutHost(host)) {
      return;
    }

    unawaited(_verifyPaymentAndClose());
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
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_loading)
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
