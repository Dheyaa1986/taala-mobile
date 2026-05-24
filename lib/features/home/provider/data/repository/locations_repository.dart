import 'package:dartz/dartz.dart';
import 'package:taal/core/options/pagination_options.dart';
import 'package:taal/features/home/provider/data/model/location_model.dart';


import '../../../../../core/error/exceptions.dart';


abstract class LocationsRepository {
  Future<Either<CustomException,List<LocationModel>>> getLocations(PaginationOptions options);

}