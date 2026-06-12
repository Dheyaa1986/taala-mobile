import 'package:dartz/dartz.dart';
import 'package:taal/core/app_config/app_urls.dart';
import 'package:taal/core/error/exceptions.dart';
import 'package:taal/core/network/network_request.dart';
import 'package:taal/core/options/pagination_options.dart';
import 'package:taal/core/repository/repository.dart';
import 'package:taal/features/home/client/data/model/service_provider_model/service_type_model.dart';
import 'package:taal/features/home/provider/data/model/governate.dart';
import 'package:taal/features/home/provider/data/model/location_model.dart';
import 'package:taal/features/home/provider/data/repository/locations_repository.dart';

class LocationsRepositoryImpl extends Repository implements LocationsRepository {
  List<T> _parseList<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) mapper,
  ) {
    final response = json['response'];
    if (response is List) {
      return response
          .map((e) => mapper(e as Map<String, dynamic>))
          .toList();
    }
    if (response is Map<String, dynamic> && response['data'] is List) {
      return (response['data'] as List)
          .map((e) => mapper(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<Either<CustomException, List<CountryModel>>> getCountries() {
    return exceptionHandler(() async {
      final json = await dioService.callApi<Map<String, dynamic>>(
        NetworkRequest(AppUrls.countriesList, method: RequestMethod.get),
      );
      return _parseList(json, CountryModel.fromJson);
    });
  }

  @override
  Future<Either<CustomException, List<GovernanceModel>>> getGovernorates(
      String countryId) {
    return exceptionHandler(() async {
      final json = await dioService.callApi<Map<String, dynamic>>(
        NetworkRequest(
          AppUrls.governoratesList(countryId),
          method: RequestMethod.get,
        ),
      );
      return _parseList(json, GovernanceModel.fromJson);
    });
  }

  @override
  Future<Either<CustomException, List<ServiceTypeModel>>> getServiceTypes() {
    return exceptionHandler(() async {
      final json = await dioService.callApi<Map<String, dynamic>>(
        NetworkRequest(AppUrls.serviceTypesList, method: RequestMethod.get),
      );
      return _parseList(json, ServiceTypeModel.fromJson);
    });
  }

  @override
  Future<Either<CustomException, List<CityModel>>> getCities(
      String governorateId) {
    return exceptionHandler(() async {
      final json = await dioService.callApi<Map<String, dynamic>>(
        NetworkRequest(
          AppUrls.citiesList(governorateId),
          method: RequestMethod.get,
        ),
      );
      return _parseList(json, CityModel.fromJson);
    });
  }

  @override
  Future<Either<CustomException, String>> resolveCityIdForIraqGovernorate(
      String governorateNameAr) {
    return exceptionHandler(() async {
      final countriesJson = await dioService.callApi<Map<String, dynamic>>(
        NetworkRequest(AppUrls.countriesList, method: RequestMethod.get),
      );
      final countries = _parseList(countriesJson, CountryModel.fromJson);
      CountryModel? iraq;
      for (final country in countries) {
        final name = country.name?.toLowerCase() ?? '';
        if (country.name == 'العراق' ||
            country.name == 'Iraq' ||
            name.contains('iraq')) {
          iraq = country;
          break;
        }
      }
      if (iraq?.id == null) {
        throw const CustomException('لم يتم العثور على العراق في قاعدة البيانات');
      }

      final governoratesJson = await dioService.callApi<Map<String, dynamic>>(
        NetworkRequest(
          AppUrls.governoratesList(iraq!.id!),
          method: RequestMethod.get,
        ),
      );
      final governoratesRaw = _extractRawList(governoratesJson);
      final target = governorateNameAr.trim();
      final governorate = governoratesRaw.firstWhere(
        (g) =>
            (g['nameAr']?.toString().trim() ?? '') == target ||
            (g['name']?.toString().trim() ?? '') == target,
        orElse: () => <String, dynamic>{},
      );
      final governorateId = governorate['id']?.toString();
      if (governorateId == null || governorateId.isEmpty) {
        throw CustomException('لم يتم العثور على محافظة $governorateNameAr');
      }

      final citiesJson = await dioService.callApi<Map<String, dynamic>>(
        NetworkRequest(
          AppUrls.citiesList(governorateId),
          method: RequestMethod.get,
        ),
      );
      final cities = _parseList(citiesJson, CityModel.fromJson);
      for (final city in cities) {
        if (city.id != null && city.id!.isNotEmpty) {
          return city.id!;
        }
      }
      throw CustomException('لا توجد مدينة مرتبطة بمحافظة $governorateNameAr');
    });
  }

  List<Map<String, dynamic>> _extractRawList(Map<String, dynamic> json) {
    final response = json['response'];
    if (response is List) {
      return response.map((e) => e as Map<String, dynamic>).toList();
    }
    if (response is Map<String, dynamic> && response['data'] is List) {
      return (response['data'] as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();
    }
    return [];
  }

  @override
  Future<Either<CustomException, List<LocationModel>>> getLocations(
      String providerId, PaginationOptions options) {
    return exceptionHandler(() async {
      final json = await dioService.callApi<Map<String, dynamic>>(
        NetworkRequest(
          AppUrls.providerLocations(providerId),
          method: RequestMethod.get,
          queryParameters: {
            'page': options.page,
            'limit': options.limit,
            if (options.search != null) 'search': options.search,
          },
        ),
      );
      return _parseList(json, LocationModel.fromJson);
    });
  }

  @override
  Future<Either<CustomException, LocationModel>> addLocation({
    required String cityId,
    required String googleMapsUrl,
    double? latitude,
    double? longitude,
  }) {
    return exceptionHandler(() async {
      final json = await dioService.callApi<Map<String, dynamic>>(
        NetworkRequest(
          AppUrls.providerLocationsCreate,
          method: RequestMethod.post,
          body: {
            'cityId': cityId,
            'googleMapsUrl': googleMapsUrl,
            if (latitude != null) 'latitude': latitude,
            if (longitude != null) 'longitude': longitude,
          },
        ),
      );
      return LocationModel.fromJson(json);
    });
  }

  @override
  Future<Either<CustomException, LocationModel>> updateLocation({
    required String providerId,
    required String locationId,
    required String cityId,
    required String googleMapsUrl,
  }) {
    return exceptionHandler(() async {
      final json = await dioService.callApi<Map<String, dynamic>>(
        NetworkRequest(
          AppUrls.providerLocation(providerId, locationId),
          method: RequestMethod.patch,
          body: {
            'cityId': cityId,
            'googleMapsUrl': googleMapsUrl,
          },
        ),
      );
      return LocationModel.fromJson(json);
    });
  }

  @override
  Future<Either<CustomException, bool>> deleteLocation({
    required String providerId,
    required String locationId,
  }) {
    return exceptionHandler(() async {
      await dioService.callApi(
        NetworkRequest(
          AppUrls.providerLocation(providerId, locationId),
          method: RequestMethod.delete,
        ),
      );
      return true;
    });
  }
}
