import 'package:dartz/dartz.dart';
import 'package:taal/core/options/pagination_options.dart';
import 'package:taal/features/home/client/data/model/service_provider_model/service_provider_model.dart';
import 'package:taal/features/home/provider/data/model/location_model.dart';


import '../../../../../core/error/exceptions.dart';


abstract class ProviderRepository {
  Future<Either<CustomException,List<ServiceProviderModel>>> getProviders(PaginationOptions options);

}