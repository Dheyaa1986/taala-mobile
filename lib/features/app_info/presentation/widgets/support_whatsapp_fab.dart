import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_icons.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/widgets/svg_image/svg_image_widget.dart';
import 'package:taal/features/app_info/data/model/app_public_info_model.dart';
import 'package:taal/features/app_info/presentation/widgets/support_whatsapp_helper.dart';

class SupportWhatsAppFab extends StatefulWidget {
  const SupportWhatsAppFab({super.key});

  @override
  State<SupportWhatsAppFab> createState() => _SupportWhatsAppFabState();
}

class _SupportWhatsAppFabState extends State<SupportWhatsAppFab> {
  AppPublicInfoModel? _info;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final info = await SupportWhatsAppHelper.load();
    if (!mounted) return;
    setState(() => _info = info);
  }

  @override
  Widget build(BuildContext context) {
    if (_info == null) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: 72.h),
      child: FloatingActionButton(
        heroTag: 'support_whatsapp_fab',
        backgroundColor: const Color(0xFF25D366),
        tooltip: AppStrings.contactSupportWhatsApp.tr(),
        onPressed: () => SupportWhatsAppHelper.open(),
        child: SvgImageWidget(
          image: AppIcons.whatsapp,
          width: 28.r,
          height: 28.r,
        ),
      ),
    );
  }
}
