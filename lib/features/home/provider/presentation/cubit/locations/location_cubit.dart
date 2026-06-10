import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/options/pagination_options.dart';
import 'package:taal/features/home/provider/data/model/location_model.dart';
import 'package:taal/features/home/provider/data/repository/locations_repository.dart';
import 'package:taal/features/profile/data/repository/profile_repository.dart';

part 'location_state.dart';

class LocationCubit extends Cubit<LocationState> {
  LocationCubit(this.repository) : super(LocationInitial());

  final LocationsRepository repository;

  int page = 1;
  final int pageSize = 20;
  bool reachedMax = false;
  List<LocationModel> locations = [];
  String? _providerId;

  Future<String?> _resolveProviderId() async {
    if (_providerId != null) return _providerId;
    final result = await getIt<ProfileRepository>().getMyProfile();
    return result.fold((_) => null, (profile) {
      _providerId = profile.id;
      return _providerId;
    });
  }

  Future<void> getLocations({bool reset = false, String? query}) async {
    emit(LocationsLoading());
    final providerId = await _resolveProviderId();
    if (providerId == null) {
      emit(LocationsError('Failed to load provider profile'));
      return;
    }

    if (reset) {
      page = 1;
      locations = [];
      reachedMax = false;
    }

    final result = await repository.getLocations(
      providerId,
      PaginationOptions(page: page, limit: pageSize, search: query),
    );

    result.fold(
      (error) => emit(LocationsError(error.message)),
      (items) {
        locations = reset ? items : [...locations, ...items];
        reachedMax = items.length < pageSize;
        emit(LocationsLoaded(locations: locations, reachedMax: reachedMax));
      },
    );
  }

  Future<void> addLocation(LocationModel location) async {
    final cityId = location.cityId ?? location.city?.id;
    final mapUrl = location.mapLink;
    if (cityId == null || mapUrl == null || mapUrl.isEmpty) {
      emit(LocationsError('City and map link are required'));
      return;
    }

    emit(LocationsLoading());
    final result = await repository.addLocation(
      cityId: cityId,
      googleMapsUrl: mapUrl,
    );

    await result.fold(
      (error) async => emit(LocationsError(error.message)),
      (_) async => getLocations(reset: true),
    );
  }

  Future<void> deleteLocation(LocationModel location) async {
    final providerId = await _resolveProviderId();
    if (providerId == null || location.id == null) return;

    emit(LocationsLoading());
    final result = await repository.deleteLocation(
      providerId: providerId,
      locationId: location.id!,
    );

    await result.fold(
      (error) async => emit(LocationsError(error.message)),
      (_) async => getLocations(reset: true),
    );
  }

  Future<void> updateLocation(LocationModel location) async {
    final providerId = await _resolveProviderId();
    final cityId = location.cityId ?? location.city?.id;
    final mapUrl = location.mapLink;
    if (providerId == null ||
        location.id == null ||
        cityId == null ||
        mapUrl == null) {
      emit(LocationsError('Invalid location data'));
      return;
    }

    emit(LocationsLoading());
    final result = await repository.updateLocation(
      providerId: providerId,
      locationId: location.id!,
      cityId: cityId,
      googleMapsUrl: mapUrl,
    );

    await result.fold(
      (error) async => emit(LocationsError(error.message)),
      (_) async => getLocations(reset: true),
    );
  }
}
