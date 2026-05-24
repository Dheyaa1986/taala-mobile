import 'package:dio/dio.dart';

import '../../../../core/error/errors_exceptions_handler.dart';
import '../model/country_model.dart';

class CountryService {
  final Dio _dio = Dio();

  Future<List<CountryModel>> fetchCountries() async {
    try {
      final response = await _dio.get(
          'https://restcountries.com/v3.1/all?fields=name,flags,idd');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => CountryModel.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load countries");
      }
    }on DioException catch (e) {
      return ErrorsExceptionsHandler.handleError(e);
    }
  }
}