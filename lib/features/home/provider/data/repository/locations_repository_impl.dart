import 'package:dartz/dartz.dart';
import 'package:taal/core/options/pagination_options.dart';
import 'package:taal/features/home/provider/data/model/location_model.dart';
import 'package:taal/features/home/provider/data/repository/locations_repository.dart';

import '../../../../../core/error/exceptions.dart';

class LocationsRepositoryImpl implements LocationsRepository {


  @override
  Future<Either<CustomException, List<LocationModel>>> getLocations(
      PaginationOptions options) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      List<LocationModel> data = [];
      final start = (options.page - 1) * options.limit;
      final end = start + options.limit;
      return Right(data);
    } catch (e) {
      return const Left(CustomException('Failed to fetch getSkills'));
    }
  }
}
