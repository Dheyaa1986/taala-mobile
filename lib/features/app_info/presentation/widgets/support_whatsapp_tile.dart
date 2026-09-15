import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/custom_launcher/custom_launcher.dart';
import 'package:taal/features/app_info/data/model/app_public_info_model.dart';
import 'package:taal/features/app_info/data/repository/app_public_info_repository.dart';
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
    final result = await getIt<AppPublicInfoRepository>().getPublicInfo();
    if (!mounted) return;
    result.fold(
      (_) => setState(() => _loading = false),
      (info) => setState(() {
        _info = info;
        _loading = false;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _info == null || !_info!.hasSupportWhatsApp) {
      return const SizedBox.shrink();
    }

    return SettingsTile(
      title: AppStrings.contactSupportWhatsApp.tr(),
      onTap: () => getIt<CustomLauncher>().openWhatsApp(
        _info!.supportWhatsApp!,
        message: _info!.supportWhatsAppMessage,
      ),
    );
  }
}
