import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:taal/config/routes/app_router.dart';
import 'package:taal/features/profile/client/presentation/widgets/complete_profile_sheet.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/app_config/prefs_keys.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/helpers/auth_session_helper.dart';
import 'package:taal/core/helpers/shared_pref_local_storage.dart';
import 'package:taal/core/maps/picked_location.dart';
import 'package:taal/features/home/client/data/model/service_provider_model/service_provider_model.dart';
import 'package:taal/features/service_orders/presentation/utils/order_location_prefs.dart';
import 'package:taal/features/service_orders/data/repository/service_order_repository.dart';
import 'package:taal/features/service_orders/presentation/helpers/active_order_refresh_notifier.dart';
import 'package:taal/features/service_orders/presentation/utils/service_order_navigation.dart';

class ServiceOrderChatLauncher {
  static Future<void> startChat({
    required ServiceProviderModel provider,
    required String serviceTypeId,
    required String description,
    String? serviceCategoryCode,
    int sheetsToClose = 0,
    int popRoutesBeforeDetail = 0,
    PickedLocation? clientLocation,
    PickedLocation? destinationLocation,
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

    final prefs = getIt<SharedPref>();

    if (clientLocation != null) {
      await OrderLocationPrefs.saveClient(prefs, clientLocation);
    }
    if (destinationLocation != null) {
      await OrderLocationPrefs.saveDestination(prefs, destinationLocation);
    }

    final resolvedClient = clientLocation ??
        await OrderLocationPrefs.readClient(prefs);

    final resolvedDestination = destinationLocation ??
        await OrderLocationPrefs.readDestination(prefs);
    if (resolvedDestination == null) {
      _showMessage(AppStrings.destinationRequired.tr());
      return;
    }

    final destinationAddress = resolvedDestination.address;
    final destinationLatitude = resolvedDestination.latitude;
    final destinationLongitude = resolvedDestination.longitude;

    final result = await getIt<ServiceOrderRepository>().createOrder(
      serviceTypeId: serviceTypeId,
      description: description.trim().isEmpty
          ? AppStrings.chatRequestDefault.tr()
          : description.trim(),
      providerId: provider.id,
      clientAddress: resolvedClient?.address,
      clientLatitude: resolvedClient?.latitude,
      clientLongitude: resolvedClient?.longitude,
      destinationAddress: destinationAddress,
      destinationLatitude: destinationLatitude,
      destinationLongitude: destinationLongitude,
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

        final routesToPop = popRoutesBeforeDetail + sheetsToClose;
        if (routesToPop > 0) {
          ServiceOrderNavigation.closeSheetsThenOpenDetail(
            orderId,
            sheetsToClose: routesToPop,
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
