import 'package:dartz/dartz.dart';
import 'package:taal/core/options/pagination_options.dart';
import 'package:taal/features/home/client/data/model/service_provider_model/service_type_model.dart';
import 'package:taal/features/home/provider/data/model/governate.dart';
import 'package:taal/features/home/provider/data/model/location_model.dart';

import '../../../../../core/error/exceptions.dart';

abstract class LocationsRepository {
  Future<Either<CustomException, List<CountryModel>>> getCountries();
  Future<Either<CustomException, List<GovernanceModel>>> getGovernorates(
      String countryId);
  Future<Either<CustomException, List<CityModel>>> getCities(
      String governorateId);
  Future<Either<CustomException, List<ServiceTypeModel>>> getServiceTypes();
  Future<Either<CustomException, List<LocationModel>>> getLocations(
      String providerId, PaginationOptions options);
  Future<Either<CustomException, LocationModel>> addLocation({
    required String cityId,
    required String googleMapsUrl,
  });
  Future<Either<CustomException, LocationModel>> updateLocation({
    required String providerId,
    required String locationId,
    required String cityId,
    required String googleMapsUrl,
  });
  Future<Either<CustomException, bool>> deleteLocation({
    required String providerId,
    required String locationId,
  });
}
