import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/app_config/app_icons.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/widgets/svg_image/svg_image_widget.dart';
import 'package:taal/features/app_info/data/model/app_public_info_model.dart';
import 'package:taal/features/app_info/presentation/widgets/support_whatsapp_helper.dart';

class SupportWhatsAppBanner extends StatefulWidget {
  const SupportWhatsAppBanner({super.key});

  @override
  State<SupportWhatsAppBanner> createState() => _SupportWhatsAppBannerState();
}

class _SupportWhatsAppBannerState extends State<SupportWhatsAppBanner> {
  AppPublicInfoModel? _info;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final info = await SupportWhatsAppHelper.load(forceRefresh: true);
    if (!mounted) return;
    setState(() => _info = info);
  }

  @override
  Widget build(BuildContext context) {
    if (_info == null) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Material(
        color: const Color(0xFF25D366).withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: const BorderSide(color: Color(0xFF25D366), width: 1.5),
        ),
        child: InkWell(
          onTap: () => SupportWhatsAppHelper.open(),
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: REdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: const BoxDecoration(
                    color: Color(0xFF25D366),
                    shape: BoxShape.circle,
                  ),
                  padding: EdgeInsets.all(10.r),
                  child: SvgImageWidget(
                    image: AppIcons.whatsapp,
                    width: 24.r,
                    height: 24.r,
                  ),
                ),
                12.width,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.contactSupportWhatsApp.tr(),
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.lightMainText,
                        ),
                      ),
                      4.height,
                      Text(
                        AppStrings.supportWhatsAppBannerHint.tr(),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.commentColor,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14.r,
                  color: AppColors.commentColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
