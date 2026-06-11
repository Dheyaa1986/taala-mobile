import 'package:dartz/dartz.dart';
import 'package:taal/core/app_config/app_urls.dart';
import 'package:taal/core/error/exceptions.dart';
import 'package:taal/core/network/network_request.dart';
import 'package:taal/core/repository/repository.dart';
import 'package:taal/features/notifications/data/models/notification_model.dart';

class NotificationRepository extends Repository {
  Future<Either<CustomException, NotificationsPageModel>> getMyNotifications({
    int page = 1,
    int limit = 20,
  }) {
    return exceptionHandler(() async {
      return dioService.callApi(
        NetworkRequest(
          AppUrls.notificationsMe,
          method: RequestMethod.get,
          queryParameters: {'page': page, 'limit': limit},
        ),
        mapper: (json) => NotificationsPageModel.fromJson(json),
      );
    });
  }

  Future<Either<CustomException, int>> getUnreadCount() {
    return exceptionHandler(() async {
      final json = await dioService.callApi<Map<String, dynamic>>(
        NetworkRequest(
          AppUrls.notificationsUnreadCount,
          method: RequestMethod.get,
        ),
      );
      final response = json['response'] as Map<String, dynamic>? ?? json;
      final count = response['count'];
      if (count is int) return count;
      if (count is num) return count.toInt();
      return int.tryParse(count?.toString() ?? '') ?? 0;
    });
  }

  Future<Either<CustomException, bool>> markAsRead(String id) {
    return exceptionHandler(() async {
      await dioService.callApi(
        NetworkRequest(
          AppUrls.notificationRead(id),
          method: RequestMethod.patch,
        ),
      );
      return true;
    });
  }

  Future<Either<CustomException, bool>> markAllAsRead() {
    return exceptionHandler(() async {
      await dioService.callApi(
        NetworkRequest(
          AppUrls.notificationsReadAll,
          method: RequestMethod.patch,
        ),
      );
      return true;
    });
  }
}
