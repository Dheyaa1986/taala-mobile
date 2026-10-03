import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/helpers/guest_session_helper.dart';
import 'package:taal/design_system/theme/taala_tokens.dart';

class GuestWelcomeBanner extends StatelessWidget {
  const GuestWelcomeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: GuestSessionHelper.isGuestBrowsing(),
      builder: (context, snapshot) {
        if (snapshot.data != true) return const SizedBox.shrink();
        return _GuestWelcomeBannerBody(tokens: TaalaTokens.of(context));
      },
    );
  }
}

class _GuestWelcomeBannerBody extends StatelessWidget {
  const _GuestWelcomeBannerBody({required this.tokens});

  final TaalaTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: tokens.primary.withValues(alpha: 0.12),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          child: Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                color: tokens.primary,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  AppStrings.guestWelcomeBanner.tr(),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: tokens.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              TextButton(
                onPressed: () => GuestSessionHelper.returnToStart(context),
                child: Text(
                  AppStrings.guestReturnToStart.tr(),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: tokens.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
