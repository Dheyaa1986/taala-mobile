import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/features/app_info/data/model/app_public_info_model.dart';
import 'package:taal/features/app_info/presentation/widgets/support_whatsapp_helper.dart';
import 'package:taal/features/profile/client/presentation/widgets/settings_tile.dart';

class SupportWhatsAppTile extends StatefulWidget {
  const SupportWhatsAppTile({super.key});

  @override
  State<SupportWhatsAppTile> createState() => _SupportWhatsAppTileState();
}

class _SupportWhatsAppTileState extends State<SupportWhatsAppTile> {
  AppPublicInfoModel? _info;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final info = await SupportWhatsAppHelper.load(forceRefresh: true);
    if (!mounted) return;
    setState(() {
      _info = info;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _info == null) {
      return const SizedBox.shrink();
    }

    return SettingsTile(
      title: AppStrings.contactSupportWhatsApp.tr(),
      onTap: () => SupportWhatsAppHelper.open(),
    );
  }
}
