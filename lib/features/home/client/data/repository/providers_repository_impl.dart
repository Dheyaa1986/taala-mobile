import 'package:dartz/dartz.dart';
import 'package:taal/core/options/pagination_options.dart';
import 'package:taal/features/home/client/data/repository/providers_repository.dart';
import 'package:taal/features/home/provider/data/model/location_model.dart';
import 'package:taal/features/home/provider/data/repository/locations_repository.dart';

import '../../../../../core/error/exceptions.dart';
import '../model/service_provider_model/service_provider_model.dart';

class ProvidersRepositoryImpl implements ProviderRepository {


  @override
  Future<Either<CustomException, List<ServiceProviderModel>>> getProviders(
      PaginationOptions options) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      List<ServiceProviderModel> data = [];
      final start = (options.page - 1) * options.limit;
      final end = start + options.limit;
      return Right(data);
    } catch (e) {
      return const Left(CustomException('Failed to fetch getSkills'));
    }
  }
}
