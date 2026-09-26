import 'package:taal/core/app_config/app_urls.dart';
import 'package:taal/core/network/api_response_helper.dart';
import 'package:taal/core/network/dio_service.dart';
import 'package:taal/core/network/network_request.dart';
import 'package:taal/core/remote_config_helper/remote_config_helper.dart';
import 'package:taal/core/updates/app_version_requirements.dart';

class AppVersionConfigProvider {
  AppVersionConfigProvider(this._remoteConfigHelper, this._dioService);

  final RemoteConfigHelper _remoteConfigHelper;
  final DioService _dioService;

  AppVersionRequirements _requirements = AppVersionRequirements.empty;

  AppVersionRequirements get requirements => _requirements;

  Future<void> refresh() async {
    final remoteRequirements = _readFromRemoteConfig();
    AppVersionRequirements apiRequirements = AppVersionRequirements.empty;

    try {
      apiRequirements = await _fetchFromApi();
    } catch (_) {
      // Offline or API unavailable — keep Remote Config / cached values.
    }

    _requirements = remoteRequirements.merge(apiRequirements);
  }

  AppVersionRequirements _readFromRemoteConfig() {
    return AppVersionRequirements(
      androidMinimumBuild: _remoteConfigHelper.getAndroidMinimumAppBuild(),
      iosMinimumBuild: _remoteConfigHelper.getIosMinimumAppBuild(),
      androidRecommendedBuild: _remoteConfigHelper.getAndroidRecommendedAppBuild(),
      iosRecommendedBuild: _remoteConfigHelper.getIosRecommendedAppBuild(),
      androidStoreUrl: _remoteConfigHelper.getAndroidStoreUrl(),
      iosStoreUrl: _remoteConfigHelper.getIosStoreUrl(),
      iosAppStoreId: _remoteConfigHelper.getIosAppStoreId(),
    );
  }

  Future<AppVersionRequirements> _fetchFromApi() async {
    final json = await _dioService.callApi(
      NetworkRequest(
        AppUrls.appPublicInfo,
        method: RequestMethod.get,
        requestWithOutToken: true,
      ),
    ).timeout(const Duration(seconds: 8));

    final payload = ApiResponseHelper.unwrap(json);
    return AppVersionRequirements.fromJson(payload);
  }
}
