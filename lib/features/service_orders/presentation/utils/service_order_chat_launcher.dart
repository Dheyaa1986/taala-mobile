import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/config/routes/app_router.dart';
import 'package:taal/features/profile/client/presentation/widgets/complete_profile_sheet.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/app_config/prefs_keys.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/helpers/auth_session_helper.dart';
import 'package:taal/core/helpers/shared_pref_local_storage.dart';
import 'package:taal/features/home/client/data/model/service_provider_model/service_provider_model.dart';
import 'package:taal/features/service_orders/data/repository/service_order_repository.dart';
import 'package:taal/features/service_orders/presentation/helpers/active_order_refresh_notifier.dart';
import 'package:taal/features/service_orders/presentation/utils/service_order_navigation.dart';

class ServiceOrderChatLauncher {
  static Future<void> startChat({
    required ServiceProviderModel provider,
    required String serviceTypeId,
    required String description,
    int sheetsToClose = 0,
  }) async {
    final hasSession = await AuthSessionHelper.hasActiveSession();
    if (!hasSession) {
      _showMessage(AppStrings.loginRequiredForHelp.tr());
      return;
    }

    final isProvider =
        getIt<SharedPref>().get(key: PrefsKeys.isProviderAccount) == true;
    if (isProvider) {
      _showMessage(AppStrings.helpRequestClientsOnly.tr());
      return;
    }

    if (provider.id == null || provider.id!.isEmpty) {
      _showMessage(AppStrings.chatProviderUnavailable.tr());
      return;
    }

    final context = AppRouter.appNavigatorKey.currentContext;
    if (context != null && context.mounted) {
      final allowed = await ClientProfileGuard.ensureReadyForNewOrder(context);
      if (!allowed) return;
    }

    final prefs = getIt<SharedPref>();
    final address = await prefs.get(key: PrefsKeys.clientLocationAddress);
    final lat = await prefs.get(key: PrefsKeys.clientLocationLat);
    final lng = await prefs.get(key: PrefsKeys.clientLocationLng);

    final result = await getIt<ServiceOrderRepository>().createOrder(
      serviceTypeId: serviceTypeId,
      description: description.trim().isEmpty
          ? AppStrings.chatRequestDefault.tr()
          : description.trim(),
      providerId: provider.id,
      clientAddress: address is String ? address : null,
      clientLatitude: lat is String ? double.tryParse(lat) : null,
      clientLongitude: lng is String ? double.tryParse(lng) : null,
    );

    result.fold(
      (error) {
        final context = AppRouter.appNavigatorKey.currentContext;
        if (context != null &&
            context.mounted &&
            error.message.contains('ملفك')) {
          ClientProfileGuard.ensureReadyForNewOrder(context);
          return;
        }
        _showMessage(error.message);
      },
      (order) {
        final orderId = order.id;
        if (orderId == null || orderId.isEmpty) {
          _showMessage(AppStrings.chatOpenFailed.tr());
          return;
        }

        if (sheetsToClose > 0) {
          ServiceOrderNavigation.closeSheetsThenOpenDetail(
            orderId,
            sheetsToClose: sheetsToClose,
            openChat: true,
          );
        } else {
          ServiceOrderNavigation.openDetail(orderId, openChat: true);
        }
        getIt<ActiveOrderRefreshNotifier>().notifyChanged();
      },
    );
  }

  static void _showMessage(String message) {
    final context = AppRouter.appNavigatorKey.currentContext;
    if (context == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
