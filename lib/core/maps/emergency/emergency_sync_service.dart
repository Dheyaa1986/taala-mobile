import 'package:taal/core/app_config/app_urls.dart';
import 'package:taal/core/helpers/connectivity_helper.dart';
import 'package:taal/core/maps/emergency/emergency_request_queue.dart';
import 'package:taal/core/network/dio_service.dart';
import 'package:taal/core/network/network_request.dart';
import 'package:taal/features/guest/data/models/guest_help_response_model.dart';

class EmergencySyncService {
  EmergencySyncService(this._dioService, this._queue);

  final DioService _dioService;
  final EmergencyRequestQueue _queue;

  Future<int> flushPending() async {
    if (!await ConnectivityHelper.connected) {
      return 0;
    }

    final pending = await _queue.loadAll();
    var sentCount = 0;

    for (final item in pending) {
      try {
        await _dioService.callApi(
          NetworkRequest(
            AppUrls.guestHelpRequest,
            method: RequestMethod.post,
            requestWithOutToken: true,
            body: item.toHelpRequestBody(),
          ),
          mapper: (json) => GuestHelpResponseModel.fromJson(json),
        );
        await _queue.remove(item.clientRequestId);
        sentCount++;
      } catch (_) {
        // Keep remaining items for the next sync attempt.
        break;
      }
    }

    return sentCount;
  }
}
