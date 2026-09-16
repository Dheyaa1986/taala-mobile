import 'package:taal/core/custom_launcher/custom_launcher.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/features/app_info/data/model/app_public_info_model.dart';
import 'package:taal/features/app_info/data/repository/app_public_info_repository.dart';

class SupportWhatsAppHelper {
  const SupportWhatsAppHelper._();

  static Future<AppPublicInfoModel?> load({bool forceRefresh = false}) async {
    if (forceRefresh) {
      getIt<AppPublicInfoRepository>().clearCache();
    }
    final result = await getIt<AppPublicInfoRepository>().getPublicInfo(
      forceRefresh: forceRefresh,
    );
    return result.fold(
      (_) => null,
      (info) => info.hasSupportWhatsApp ? info : null,
    );
  }

  static Future<void> open({bool forceRefresh = false}) async {
    final info = await load(forceRefresh: forceRefresh);
    if (info == null) return;
    await getIt<CustomLauncher>().openWhatsApp(
      info.supportWhatsApp!,
      message: info.supportWhatsAppMessage,
    );
  }
}
