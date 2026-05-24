import 'package:dartz/dartz.dart';
import 'package:taal/core/options/pagination_options.dart';
import 'package:taal/features/rating/client/data/model/client_ratings.dart';
import 'package:taal/features/rating/client/data/repository/providers_repository.dart';

import '../../../../../core/error/exceptions.dart';

class ClientRatingsRepositoryImpl implements ClientRatingsRepository {


  @override
  Future<Either<CustomException, List<ClientRatingsModel>>> getClientRatings(
      PaginationOptions options) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      List<ClientRatingsModel> data = [];
      final start = (options.page - 1) * options.limit;
      final end = start + options.limit;
      return Right(data);
    } catch (e) {
      return const Left(CustomException('Failed to fetch getSkills'));
    }
  }
}
