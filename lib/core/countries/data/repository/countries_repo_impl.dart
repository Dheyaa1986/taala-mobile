import 'package:dartz/dartz.dart';



import '../../../error/exceptions.dart';
import '../model/country_model.dart';
import '../services/countries_services.dart';
import 'countries_repository.dart';

class CountriesRepositoryImpl extends CountriesRepository {
  CountryService service;
  CountriesRepositoryImpl({required this.service});
  @override
  Future<Either<CustomException, List<CountryModel>>> getCountries() async {
    try {
      List<CountryModel> countries = await service.fetchCountries();
      return Right(countries);
    } on CustomException catch (e) {
      return Left(e);
    } catch(e){
      return left(const CustomException('Error Loading countries'));
    }
  }
}
