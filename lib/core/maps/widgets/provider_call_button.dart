import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/design_system/theme/taala_tokens.dart';
import 'package:taal/core/maps/emergency/emergency_call_repository.dart';
import 'package:url_launcher/url_launcher.dart';

class ProviderCallButton extends StatefulWidget {
  const ProviderCallButton({
    super.key,
    required this.providerId,
    required this.latitude,
    required this.longitude,
  });

  final String providerId;
  final double latitude;
  final double longitude;

  @override
  State<ProviderCallButton> createState() => _ProviderCallButtonState();
}

class _ProviderCallButtonState extends State<ProviderCallButton> {
  bool _loading = false;

  Future<void> _call() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final dialUri = await getIt<EmergencyCallRepository>().createDialUri(
        providerId: widget.providerId,
        latitude: widget.latitude,
        longitude: widget.longitude,
      );
      final uri = Uri.parse(dialUri);
      if (!await launchUrl(uri)) {
        throw StateError('Could not launch dialer');
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.callFailedCheckInternet.tr())),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = TaalaTokens.of(context);
    return SizedBox(
      height: 40.h,
      child: FilledButton.icon(
        onPressed: _loading ? null : _call,
        icon: _loading
            ? SizedBox(
                width: 16.r,
                height: 16.r,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: tokens.onPrimary,
                ),
              )
            : const Icon(Icons.phone_rounded, size: 18),
        label: Text(AppStrings.callShort.tr()),
        style: FilledButton.styleFrom(
          backgroundColor: tokens.primary,
          foregroundColor: tokens.onPrimary,
        ),
      ),
    );
  }
}
