import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_icons.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/widgets/svg_image/svg_image_widget.dart';
import 'package:taal/features/app_info/data/model/app_public_info_model.dart';
import 'package:taal/features/app_info/presentation/widgets/support_whatsapp_helper.dart';

class SupportWhatsAppAppBarButton extends StatefulWidget {
  const SupportWhatsAppAppBarButton({super.key});

  @override
  State<SupportWhatsAppAppBarButton> createState() =>
      _SupportWhatsAppAppBarButtonState();
}

class _SupportWhatsAppAppBarButtonState
    extends State<SupportWhatsAppAppBarButton> {
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

    return IconButton(
      tooltip: AppStrings.contactSupportWhatsApp.tr(),
      onPressed: () => SupportWhatsAppHelper.open(),
      icon: Container(
        width: 36.r,
        height: 36.r,
        decoration: const BoxDecoration(
          color: Color(0xFF25D366),
          shape: BoxShape.circle,
        ),
        padding: EdgeInsets.all(7.r),
        child: SvgImageWidget(
          image: AppIcons.whatsapp,
          width: 20.r,
          height: 20.r,
        ),
      ),
    );
  }
}
