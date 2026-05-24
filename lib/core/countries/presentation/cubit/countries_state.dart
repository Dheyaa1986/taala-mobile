part of 'countries_cubit.dart';

@immutable
sealed class CountriesState {}

final class CountriesInitial extends CountriesState {}
final class CountriesError extends CountriesState {
  final String message;
  CountriesError({required this.message});
}
final class CountriesLoading extends CountriesState {}
final class CountriesLoaded extends CountriesState {
  final List<CountryModel> countries;
  final CountryModel country;
  CountriesLoaded({required this.countries,required this.country});
}
