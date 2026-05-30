import 'dart:io';

import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../../config/routes/app_router.dart';
import '../../config/routes/routes.dart';
import '../app_config/app_urls.dart';
import '../app_config/prefs_keys.dart';
import '../di/service_locator.dart';
import 'secure_local_storage.dart';
import 'shared_pref_local_storage.dart';

class AuthSessionHelper {
  const AuthSessionHelper._();

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

    final accessToken = await SecureLocalStorage.read(PrefsKeys.token);
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
        data: {
          'accessToken': accessToken ?? '',
          'refreshToken': refreshToken,
        },
      );
      if (response.statusCode != 200) return false;

      final data = response.data;
      if (data is! Map<String, dynamic>) return false;

      final access = data['accessToken'] as String?;
      final refresh = data['refreshToken'] as String?;
      if (access == null || access.isEmpty || refresh == null || refresh.isEmpty) {
        return false;
      }

      await SecureLocalStorage.write(PrefsKeys.token, access);
      await SecureLocalStorage.write(PrefsKeys.refreshToken, refresh);
      return isAccessTokenValid(access);
    } catch (_) {
      return false;
    }
  }

  static Future<void> clearSession() async {
    await SecureLocalStorage.delete(PrefsKeys.token);
    await SecureLocalStorage.delete(PrefsKeys.refreshToken);
    await getIt<SharedPref>().set(key: PrefsKeys.rememberMe, value: true);
  }

  static Future<void> logout() async {
    await clearSession();
    final context = AppRouter.appNavigatorKey.currentContext;
    if (context != null && context.mounted) {
      final isProvider =
          getIt<SharedPref>().get(key: PrefsKeys.isProviderAccount) == true;
      context.goNamed(Routes.login, extra: isProvider);
    }
  }
}
