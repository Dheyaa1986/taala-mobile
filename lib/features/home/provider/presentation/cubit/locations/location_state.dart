part of 'location_cubit.dart';

@immutable
sealed class LocationState {}

final class LocationInitial extends LocationState {}
final class LocationsLoading extends LocationState {}
final class LocationsLoaded extends LocationState {
  final List<LocationModel> locations;
 final bool reachedMax;
  LocationsLoaded({required this.locations, required this.reachedMax});

}
final class LocationsError extends LocationState {
  final String message;

  LocationsError(this.message);
}
final class LocationsEmpty extends LocationState {

}
