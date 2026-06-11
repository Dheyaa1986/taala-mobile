import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/app_config/prefs_keys.dart';
import 'package:taal/core/custom_launcher/custom_launcher.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/helpers/messages.dart';
import 'package:taal/core/helpers/shared_pref_local_storage.dart';
import 'package:taal/core/validations/validators.dart';
import 'package:taal/core/widgets/appbar/logo_skip_appbar.dart';
import 'package:taal/core/widgets/buttons/custom_button.dart';
import 'package:taal/core/widgets/buttons/notification_icon_button.dart';
import 'package:taal/core/widgets/fields/custom_text_field.dart';
import 'package:taal/core/widgets/svg_image/lang_popup.dart';
import 'package:taal/core/widgets/yellow_highlight_card.dart';
import 'package:taal/features/support/presentation/widgets/support_ticket_sheet.dart';

class ClientHomeView extends StatefulWidget {
  const ClientHomeView({super.key});

  @override
  State<ClientHomeView> createState() => _ClientHomeViewState();
}

class _ClientHomeViewState extends State<ClientHomeView> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _mapLinkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedLocation();
  }

  Future<void> _loadSavedLocation() async {
    final prefs = getIt<SharedPref>();
    final address = await prefs.get(key: PrefsKeys.clientLocationAddress);
    final mapLink = await prefs.get(key: PrefsKeys.clientLocationMapLink);
    if (!mounted) return;
    if (address is String) _addressController.text = address;
    if (mapLink is String) _mapLinkController.text = mapLink;
    setState(() {});
  }

  Future<void> _saveLocation() async {
    if (!_formKey.currentState!.validate()) return;
    final prefs = getIt<SharedPref>();
    await prefs.set(
      key: PrefsKeys.clientLocationAddress,
      value: _addressController.text.trim(),
    );
    await prefs.set(
      key: PrefsKeys.clientLocationMapLink,
      value: _mapLinkController.text.trim(),
    );
    if (mounted) {
      AppMessages.showSuccess(context, AppStrings.locationSaved.tr());
    }
  }

  Future<void> _openMap() async {
    final link = _mapLinkController.text.trim();
    if (link.isEmpty) return;
    await getIt<CustomLauncher>().openUrl(link);
  }

  @override
  void dispose() {
    _addressController.dispose();
    _mapLinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppStrings.home.tr(),
        centerTitle: true,
        leading: null,
        actions: const [
          NotificationIconButton(),
          LangPopup(),
        ],
      ),
      body: SingleChildScrollView(
        padding: REdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppStrings.clientHomeWelcome.tr(),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.lightMainText,
                ),
              ),
              8.height,
              Text(
                AppStrings.clientHomeSubtitle.tr(),
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.commentColor,
                  height: 1.5,
                ),
              ),
              20.height,
              YellowHighlightCard(
                isHighlighted: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      AppStrings.myLocation.tr(),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.lightMainText,
                      ),
                    ),
                    12.height,
                    CustomTextField(
                      controller: _addressController,
                      label: AppStrings.address.tr(),
                      hint: AppStrings.enterAddress.tr(),
                      validator: CustomValidators.validateEmpty,
                    ),
                    12.height,
                    CustomTextField(
                      controller: _mapLinkController,
                      label: AppStrings.mapLink.tr(),
                      hint: AppStrings.mapLink.tr(),
                      validator: CustomValidators.isValidGoogleMapLink,
                    ),
                    12.height,
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton.outlined(
                            text: AppStrings.viewOnMap.tr(),
                            onTap: _openMap,
                          ),
                        ),
                        12.width,
                        Expanded(
                          child: CustomButton.filled(
                            text: AppStrings.save.tr(),
                            onTap: _saveLocation,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              24.height,
              CustomButton.filled(
                text: AppStrings.requestHelp.tr(),
                onTap: () => showSupportTicketSheet(context),
                height: 52.h,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
