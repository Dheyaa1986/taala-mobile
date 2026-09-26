import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/updates/android_in_app_update_helper.dart';
import 'package:taal/core/updates/app_update_service.dart';
import 'package:taal/core/widgets/buttons/custom_button.dart';

class ForceUpdateScreen extends StatefulWidget {
  const ForceUpdateScreen({super.key, this.autoTryAndroidUpdate = true});

  final bool autoTryAndroidUpdate;

  @override
  State<ForceUpdateScreen> createState() => _ForceUpdateScreenState();
}

class _ForceUpdateScreenState extends State<ForceUpdateScreen>
    with WidgetsBindingObserver {
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.autoTryAndroidUpdate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleUpdateTap(silent: true);
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _recheckAfterResume();
    }
  }

  Future<void> _recheckAfterResume() async {
    final updateService = getIt<AppUpdateService>();
    await updateService.refreshConfig();
    if (!mounted) return;

    if (updateService.checkForUpdate() != AppUpdateStatus.required) {
      Navigator.of(context).maybePop();
    }
  }

  Future<void> _handleUpdateTap({bool silent = false}) async {
    if (_isUpdating) return;

    setState(() => _isUpdating = true);
    final updateService = getIt<AppUpdateService>();

    try {
      if (Platform.isAndroid) {
        final result = await updateService.tryAndroidImmediateUpdate();
        if (result == AndroidUpdateAttemptResult.started) {
          return;
        }
      }

      await updateService.openStoreListing();
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.system_update_alt_rounded,
                  size: 72.sp,
                  color: theme.colorScheme.primary,
                ),
                SizedBox(height: 24.h),
                Text(
                  AppStrings.updateIsRequiredTitle.tr(),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall,
                ),
                SizedBox(height: 12.h),
                Text(
                  AppStrings.updateIsRequiredSubtitle.tr(),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                SizedBox(height: 32.h),
                CustomButton(
                  text: AppStrings.update.tr(),
                  onTap: _isUpdating ? () {} : () => _handleUpdateTap(),
                  enabled: !_isUpdating,
                  isBackgroundGradient: true,
                ),
                if (Platform.isAndroid) ...[
                  SizedBox(height: 12.h),
                  CustomButton(
                    text: AppStrings.exit.tr(),
                    onTap: () => exit(0),
                    isBackgroundGradient: false,
                    backgroundColor: Colors.transparent,
                    style: theme.textTheme.headlineSmall!.copyWith(
                      fontSize: 16.sp,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
