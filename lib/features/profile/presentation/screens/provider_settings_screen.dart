import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/config/routes/routes.dart';
import 'package:taal/core/app_config/app_icons.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/network/dio_service.dart';
import 'package:taal/core/widgets/appbar/logo_skip_appbar.dart';
import 'package:taal/core/widgets/svg_image/svg_image_widget.dart';
import 'package:taal/design_system/theme/taala_tokens.dart';
import 'package:taal/features/app_info/data/model/app_public_info_model.dart';
import 'package:taal/features/profile/client/presentation/widgets/rate_app_sheet.dart';
import 'package:taal/features/profile/client/presentation/widgets/settings_grouped_card.dart';
import 'package:taal/features/profile/client/presentation/widgets/settings_section_header.dart';
import 'package:taal/features/profile/client/presentation/widgets/settings_theme_mode_section.dart';
import 'package:taal/features/profile/client/presentation/widgets/settings_tile.dart';
import 'package:taal/features/profile/presentation/widgets/conversation_history_panel.dart';
import 'package:taal/features/profile/presentation/widgets/delete_account_action.dart';
import 'package:taal/features/support/presentation/widgets/support_ticket_sheet.dart';

class ProviderSettingsScreen extends StatelessWidget {
  const ProviderSettingsScreen({super.key});

  static const _purple = Color(0xFF7C4DFF);
  static const _teal = Color(0xFF00897B);
  static const _amber = Color(0xFFF9A825);
  static const _orange = Color(0xFFFB8C00);
  static const _indigo = Color(0xFF3949AB);
  static const _slate = Color(0xFF607D8B);
  static const _blue = Color(0xFF1E88E5);

  @override
  Widget build(BuildContext context) {
    final tokens = TaalaTokens.of(context);

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: CustomAppBar.backAppBar(
        title: AppStrings.menu.tr(),
        centerTitle: true,
      ),
      body: ListView(
        padding: REdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const ConversationHistoryPanel(),
          20.height,
          SettingsSectionHeader(title: AppStrings.settings),
          10.height,
          const SettingsThemeModeSection(),
          20.height,
          SettingsSectionHeader(title: AppStrings.settingsSectionHelp),
          10.height,
          SettingsTile(
            title: AppStrings.mySupportTickets,
            icon: Icons.support_agent_outlined,
            iconColor: _purple,
            iconBackgroundColor: _purple.withValues(alpha: 0.12),
            onTap: () => context.pushNamed(Routes.supportTickets),
          ),
          10.height,
          SettingsTile(
            title: AppStrings.submitSupportTicket,
            icon: Icons.edit_note_outlined,
            iconColor: _teal,
            iconBackgroundColor: _teal.withValues(alpha: 0.12),
            onTap: () => showSupportTicketSheet(context),
          ),
          10.height,
          SettingsTile(
            title: AppStrings.myRatings,
            icon: Icons.star_rate_outlined,
            iconColor: _orange,
            iconBackgroundColor: _orange.withValues(alpha: 0.12),
            onTap: () => context.pushNamed(Routes.providerMyRatings),
          ),
          10.height,
          SettingsTile(
            title: AppStrings.subscriptions,
            icon: Icons.workspace_premium_outlined,
            iconColor: _indigo,
            iconBackgroundColor: _indigo.withValues(alpha: 0.12),
            onTap: () => context.pushNamed(Routes.providerSubscription),
          ),
          10.height,
          SettingsTile(
            title: AppStrings.rateApp,
            icon: Icons.star_outline_rounded,
            iconColor: _amber,
            iconBackgroundColor: _amber.withValues(alpha: 0.14),
            onTap: () => showRateAppSheet(context),
          ),
          20.height,
          SettingsSectionHeader(title: AppStrings.settingsSectionLegal),
          10.height,
          SettingsGroupedCard(
            items: [
              SettingsGroupItem(
                title: AppStrings.termsAndConditions,
                icon: Icons.description_outlined,
                iconColor: _slate,
                iconBackgroundColor: _slate.withValues(alpha: 0.12),
                onTap: () => context.pushNamed(
                  Routes.legalDocument,
                  extra: LegalDocumentType.terms,
                ),
              ),
              SettingsGroupItem(
                title: AppStrings.privacyPolicy,
                icon: Icons.shield_outlined,
                iconColor: _blue,
                iconBackgroundColor: _blue.withValues(alpha: 0.12),
                onTap: () => context.pushNamed(
                  Routes.legalDocument,
                  extra: LegalDocumentType.privacy,
                ),
              ),
            ],
          ),
          20.height,
          SettingsSectionHeader(title: AppStrings.settingsSectionAccount),
          10.height,
          SettingsTile(
            title: AppStrings.deleteAccount,
            titleColor: tokens.error,
            icon: Icons.delete_outline_rounded,
            iconColor: tokens.error,
            iconBackgroundColor: tokens.error.withValues(alpha: 0.1),
            onTap: () => confirmDeleteAccount(context),
          ),
          12.height,
          SettingsLogoutTile(
            onTap: () => getIt<DioService>().logout(),
            icon: SvgImageWidget(
              image: AppIcons.login,
              width: 24.w,
              height: 24.h,
            ),
          ),
        ],
      ),
    );
  }
}
