import 'package:taal/core/network/api_response_helper.dart';
import 'package:taal/core/app_config/app_urls.dart';
import 'package:taal/core/network/network_request.dart';
import 'package:taal/core/repository/repository.dart';
import 'package:taal/features/service_orders/data/model/service_order_model.dart';
import 'package:dartz/dartz.dart';
import 'package:taal/core/error/exceptions.dart';

abstract class ServiceOrderRepository {
  Future<Either<CustomException, ServiceOrderModel>> createOrder({
    required String serviceTypeId,
    required String description,
    String? clientAddress,
    double? clientLatitude,
    double? clientLongitude,
    String? providerId,
  });

  Future<Either<CustomException, ServiceOrderModel>> getOrder(String id);

  Future<Either<CustomException, ServiceOrderTrackingModel>> getTracking(
    String id,
  );

  Future<Either<CustomException, ServiceOrderModel>> sendMessage({
    required String orderId,
    required String message,
  });

  Future<Either<CustomException, ServiceOrderModel>> updateStatus({
    required String orderId,
    required String status,
    double? agreedPrice,
  });

  Future<Either<CustomException, List<ServiceOrderModel>>> getMyOrders({
    int page = 1,
    int limit = 20,
  });
}

class ServiceOrderRepositoryImpl extends Repository
    implements ServiceOrderRepository {
  @override
  Future<Either<CustomException, ServiceOrderModel>> createOrder({
    required String serviceTypeId,
    required String description,
    String? clientAddress,
    double? clientLatitude,
    double? clientLongitude,
    String? providerId,
  }) {
    return exceptionHandler(() async {
      final json = await dioService.callApi(
        NetworkRequest(
          AppUrls.serviceOrders,
          method: RequestMethod.post,
          body: {
            'serviceTypeId': serviceTypeId,
            'description': description,
            if (clientAddress != null) 'clientAddress': clientAddress,
            if (clientLatitude != null) 'clientLatitude': clientLatitude,
            if (clientLongitude != null) 'clientLongitude': clientLongitude,
            if (providerId != null) 'providerId': providerId,
          },
        ),
      );
      return ServiceOrderModel.fromJson(ApiResponseHelper.unwrap(json));
    });
  }

  @override
  Future<Either<CustomException, ServiceOrderModel>> getOrder(String id) {
    return exceptionHandler(() async {
      final json = await dioService.callApi(
        NetworkRequest('${AppUrls.serviceOrders}/$id', method: RequestMethod.get),
      );
      return ServiceOrderModel.fromJson(ApiResponseHelper.unwrap(json));
    });
  }

  @override
  Future<Either<CustomException, ServiceOrderTrackingModel>> getTracking(
    String id,
  ) {
    return exceptionHandler(() async {
      final json = await dioService.callApi(
        NetworkRequest(
          AppUrls.serviceOrderTracking(id),
          method: RequestMethod.get,
        ),
      );
      return ServiceOrderTrackingModel.fromJson(ApiResponseHelper.unwrap(json));
    });
  }

  @override
  Future<Either<CustomException, ServiceOrderModel>> sendMessage({
    required String orderId,
    required String message,
  }) {
    return exceptionHandler(() async {
      final json = await dioService.callApi(
        NetworkRequest(
          AppUrls.serviceOrderMessages(orderId),
          method: RequestMethod.post,
          body: {'message': message},
        ),
      );
      return ServiceOrderModel.fromJson(ApiResponseHelper.unwrap(json));
    });
  }

  @override
  Future<Either<CustomException, ServiceOrderModel>> updateStatus({
    required String orderId,
    required String status,
    double? agreedPrice,
  }) {
    return exceptionHandler(() async {
      final json = await dioService.callApi(
        NetworkRequest(
          AppUrls.serviceOrderStatus(orderId),
          method: RequestMethod.patch,
          body: {
            'status': status,
            if (agreedPrice != null) 'agreedPrice': agreedPrice,
          },
        ),
      );
      return ServiceOrderModel.fromJson(ApiResponseHelper.unwrap(json));
    });
  }

  @override
  Future<Either<CustomException, List<ServiceOrderModel>>> getMyOrders({
    int page = 1,
    int limit = 20,
  }) {
    return exceptionHandler(() async {
      final json = await dioService.callApi(
        NetworkRequest(
          AppUrls.serviceOrdersMe,
          method: RequestMethod.get,
          queryParameters: {'page': page, 'limit': limit},
        ),
      );
      final response = ApiResponseHelper.unwrap(json);
      final data = response['data'] as List<dynamic>? ?? [];
      final orders = <ServiceOrderModel>[];
      for (final item in data) {
        try {
          orders.add(
            ServiceOrderModel.fromJson(ApiResponseHelper.asMap(item)),
          );
        } catch (_) {
          continue;
        }
      }
      return orders;
    });
  }
}
