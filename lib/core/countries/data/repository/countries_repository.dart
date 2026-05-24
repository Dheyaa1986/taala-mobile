import 'package:dartz/dartz.dart';



import '../../../error/exceptions.dart';
import '../model/country_model.dart';



abstract class CountriesRepository {

  Future<Either<CustomException, List<CountryModel>>> getCountries();
}
