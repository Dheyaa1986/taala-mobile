import 'package:taal/core/app_config/app_urls.dart';
import 'package:taal/core/network/dio_service.dart';
import 'package:taal/core/network/network_request.dart';

class EmergencyCallRepository {
  EmergencyCallRepository(this._dioService);

  final DioService _dioService;

  Future<String> createDialUri({
    required String providerId,
    required double latitude,
    required double longitude,
  }) async {
    final json = await _dioService.callApi<Map<String, dynamic>>(
      NetworkRequest(
        AppUrls.emergencyProviderCallSession(providerId),
        method: RequestMethod.post,
        requestWithOutToken: true,
        body: {
          'clientLatitude': latitude,
          'clientLongitude': longitude,
          'context': 'guest_emergency',
        },
      ),
    );
    final response = json['response'] as Map<String, dynamic>? ?? json;
    final dialUri = response['dialUri']?.toString();
    if (dialUri == null || dialUri.isEmpty) {
      throw StateError('Call session unavailable');
    }
    return dialUri;
  }
}
