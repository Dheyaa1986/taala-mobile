import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/config/routes/routes.dart';
import 'package:taal/core/helpers/auth_session_helper.dart';
import 'package:taal/features/subscriptions/data/repository/subscription_repository.dart';

class ProviderSubscriptionGate {
  const ProviderSubscriptionGate._();

  static bool? _canReceiveOrders;

  static void invalidate() {
    _canReceiveOrders = null;
  }

  static Future<bool> providerNeedsSubscription() async {
    if (!await AuthSessionHelper.isProviderSession()) {
      return false;
    }

    if (_canReceiveOrders != null) {
      return !_canReceiveOrders!;
    }

    final result = await SubscriptionRepository().getMySubscription();
    return result.fold(
      (_) => true,
      (subscription) {
        _canReceiveOrders = subscription.canReceiveOrders;
        return !subscription.canReceiveOrders;
      },
    );
  }

  static Future<void> navigateAfterAuth(BuildContext context) async {
    if (!context.mounted) return;

    if (await providerNeedsSubscription()) {
      context.goNamed(Routes.providerSubscriptionRequired);
      return;
    }

    context.goNamed(Routes.home);
  }

  static bool isPublicRoute(String location) {
    return location == Routes.splashScreen ||
        location == Routes.guestMap ||
        location == Routes.login ||
        location == Routes.register ||
        location == Routes.selectRoleScreen ||
        location == Routes.providerRegisterSteps ||
        location == Routes.registrationOtp ||
        location == Routes.providerSubscriptionRequired;
  }
}
