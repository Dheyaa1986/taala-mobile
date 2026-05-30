import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../data/model/country_model.dart';
import '../../data/repository/countries_repository.dart';

part 'countries_state.dart';

class CountriesCubit extends Cubit<CountriesState> {
  CountriesCubit(this.countriesRepository) : super(CountriesInitial());
  CountriesRepository countriesRepository;
  List<CountryModel> countries = [];
  CountryModel? selectedCountry;

  getCountries() async {
    emit(CountriesLoading());
    final result = await countriesRepository.getCountries();
    result.fold(
      (failure) {
        emit(CountriesError(message: failure.message));
      },
      (countriesList) {
        countries = countriesList;
        countries = _moveIraqToFirst(countriesList);
        selectedCountry = _select("+964");
        emit(
          CountriesLoaded(countries: countries, country: selectedCountry!),
        );
      },
    );
  }

  List<CountryModel> _moveIraqToFirst(List<CountryModel> list) {
    final List<CountryModel> newList = List.from(list);

    int iraqIndex = newList.indexWhere((country) =>
        country.code == '+964' ||
        country.name == 'Iraq' ||
        country.name == 'العراق');

    if (iraqIndex != -1 && iraqIndex != 0) {
      final iraq = newList.removeAt(iraqIndex);
      newList.insert(0, iraq);
    }

    return newList;
  }

  CountryModel _select(code) => countries.firstWhere(
        (element) => element.code == code,
        orElse: () => countries.first,
      );

  selectCountry(code) {
    final state = this.state;
    if (state is CountriesLoaded) {
      print('ccc code $code');
      selectedCountry = _select(code);

      emit(
        CountriesLoaded(countries: state.countries, country: selectedCountry!),
      );
    }
  }
}
