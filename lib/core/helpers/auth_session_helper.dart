import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../../config/routes/app_router.dart';
import '../../config/routes/routes.dart';
import '../app_config/app_urls.dart';
import '../app_config/prefs_keys.dart';
import '../alerts/app_alert_monitor.dart';
import '../alerts/app_icon_badge_service.dart';
import '../di/service_locator.dart';
import '../../features/subscriptions/presentation/utils/provider_subscription_gate.dart';
import '../widgets/bottom_nav_bar/cubit/bottom_navigation_cubit.dart';
import 'guest_session_helper.dart';
import 'messages.dart';
import 'secure_local_storage.dart';
import 'shared_pref_local_storage.dart';

class AuthSessionHelper {
  const AuthSessionHelper._();

  static const int providerRole = 3;

  static bool isAccessTokenValid(String? token) {
    if (token == null || token.isEmpty) return false;
    try {
      return !JwtDecoder.isExpired(token);
    } catch (_) {
      return false;
    }
  }

  static Future<bool> hasActiveSession() async {
    final token = await SecureLocalStorage.read(PrefsKeys.token);
    if (isAccessTokenValid(token)) return true;
    return tryRefreshSession();
  }

  static Future<bool> tryRefreshSession() async {
    final refreshToken =
        await SecureLocalStorage.read(PrefsKeys.refreshToken);
    if (refreshToken == null || refreshToken.isEmpty) return false;

    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            HttpHeaders.acceptHeader: ContentType.json.mimeType,
            'accept-language': 'ar',
            'time-zone': 'Asia/Baghdad',
          },
        ),
      );
      final response = await dio.post(
        AppUrls.refreshToken,
        data: {'refreshToken': refreshToken},
      );
      if (response.statusCode != 200) return false;

      final raw = response.data;
      if (raw is! Map<String, dynamic>) return false;

      final payload =
          raw['response'] as Map<String, dynamic>? ?? raw;
      final access = payload['token']?.toString() ?? '';
      final refresh = payload['refreshToken']?.toString() ?? '';
      if (access.isEmpty || refresh.isEmpty) {
        return false;
      }

      await SecureLocalStorage.write(PrefsKeys.token, access);
      await SecureLocalStorage.write(PrefsKeys.refreshToken, refresh);
      return isAccessTokenValid(access);
    } catch (_) {
      return false;
    }
  }

  static Future<bool> isProviderSession() async {
    final token = await SecureLocalStorage.read(PrefsKeys.token);
    if (isAccessTokenValid(token)) {
      try {
        final payload = JwtDecoder.decode(token!);
        final role = payload['role'];
        final isProvider = role is int
            ? role == providerRole
            : int.tryParse(role?.toString() ?? '') == providerRole;
        await _persistAccountType(isProvider);
        return isProvider;
      } catch (_) {
        // Fall back to persisted account type.
      }
    }
    return getIt<SharedPref>().get(key: PrefsKeys.isProviderAccount) == true;
  }

  static Future<void> _persistAccountType(bool isProvider) async {
    final current = getIt<SharedPref>().get(key: PrefsKeys.isProviderAccount);
    if (current == isProvider) return;
    await getIt<SharedPref>().set(
      key: PrefsKeys.isProviderAccount,
      value: isProvider,
    );
  }

  static void syncNavigationRole(bool isProvider) {
    final context = AppRouter.appNavigatorKey.currentContext;
    if (context != null && context.mounted) {
      context.read<BottomNavigationCubit>().setIsProvider(isProvider);
    }
  }

  static Future<void> establishClientSession({
    required String token,
    required String refreshToken,
  }) async {
    await getIt<SharedPref>().set(
      key: PrefsKeys.isProviderAccount,
      value: false,
    );
    await SecureLocalStorage.write(PrefsKeys.token, token);
    await SecureLocalStorage.write(PrefsKeys.refreshToken, refreshToken);
    await GuestSessionHelper.clearGuestBrowsing();
    syncNavigationRole(false);
  }

  static Future<void> clearSession({bool clearRememberedCredentials = false}) async {
    await SecureLocalStorage.delete(PrefsKeys.token);
    await SecureLocalStorage.delete(PrefsKeys.refreshToken);
    await SecureLocalStorage.delete(PrefsKeys.user);
    await SecureLocalStorage.delete(PrefsKeys.password);
    if (clearRememberedCredentials) {
      await SecureLocalStorage.delete(PrefsKeys.mailOrPhone);
    }
  }

  static Future<void> logout() async {
    getIt<AppAlertMonitor>().stop();
    await getIt<AppIconBadgeService>().updateCount(0);
    ProviderSubscriptionGate.invalidate();
    await clearSession();
    await GuestSessionHelper.clearGuestBrowsing();
    final context = AppRouter.appNavigatorKey.currentContext;
    if (context != null && context.mounted) {
      context.read<BottomNavigationCubit>().setIsProvider(false);
      context.goNamed(Routes.guestMap);
    }
  }

  static void _prepareNavigation() {
    AppMessages.hideLoading();
    FocusManager.instance.primaryFocus?.unfocus();
  }

  static Future<void> goToLoginAfterRegistration({
    required bool isProvider,
  }) async {
    _prepareNavigation();
    await getIt<SharedPref>().set(
      key: PrefsKeys.isProviderAccount,
      value: isProvider,
    );
    syncNavigationRole(isProvider);
    try {
      await GuestSessionHelper.clearGuestBrowsing();
    } catch (_) {}
    AppRouter.router.go(Routes.login, extra: isProvider);
    unawaited(_clearLeftoverSession());
  }

  static Future<void> _clearLeftoverSession() async {
    try {
      await clearSession();
      await GuestSessionHelper.clearGuestBrowsing();
    } catch (_) {}
  }

  static Future<void> openAuthenticatedApp(BuildContext context) async {
    _prepareNavigation();
    final isProviderAccount =
        getIt<SharedPref>().get(key: PrefsKeys.isProviderAccount) == true;
    syncNavigationRole(isProviderAccount);
    if (!isProviderAccount) {
      AppRouter.router.go(Routes.home);
      return;
    }
    var needsSubscription = true;
    try {
      needsSubscription = await ProviderSubscriptionGate.providerNeedsSubscription()
          .timeout(const Duration(seconds: 6), onTimeout: () => true);
    } catch (_) {
      needsSubscription = true;
    }
    AppRouter.router.go(
      needsSubscription
          ? Routes.providerSubscriptionRequired
          : Routes.home,
    );
  }
}
