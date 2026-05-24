import 'package:dartz/dartz.dart';
import 'package:taal/core/options/pagination_options.dart';
import 'package:taal/features/home/client/data/model/service_provider_model/service_provider_model.dart';
import 'package:taal/features/home/provider/data/model/location_model.dart';


import '../../../../../core/error/exceptions.dart';
import '../model/client_ratings.dart';


abstract class ClientRatingsRepository {
  Future<Either<CustomException,List<ClientRatingsModel>>> getClientRatings(PaginationOptions options);

}