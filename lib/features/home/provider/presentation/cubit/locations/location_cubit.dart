import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:taal/core/options/pagination_options.dart';
import 'package:taal/features/home/provider/data/model/location_model.dart';
import 'package:taal/features/home/provider/data/repository/locations_repository.dart';

import '../../../data/model/governate.dart';

part 'location_state.dart';

class LocationCubit extends Cubit<LocationState> {
  LocationCubit(this.repository) : super(LocationInitial());

  LocationsRepository repository;

  int page = 1;
  final int pageSize = 10;
  bool reachedMax = false;
  List<LocationModel> locations = [];
  String searchQuery = '';

  void resetPagination() {
    locations = [];
    page = 1;
    reachedMax = false;
  }

  getLocations({bool reset = false, String? query,}) async {
    emit(LocationsLoading());
     Future.delayed(const Duration(seconds: 1));
     locations = List.generate(10, (index) =>  LocationModel(
       id: '$index',
       governance: GovernanceModel(name: 'Alexandria', id: 3),
       city:CityModel(name: 'Nasr City', id: 101),
       region: RegionModel(name: 'Downtown', id: 1003),
       lat: '30.0444',
       lng: '31.2357',
     ),);
     emit(LocationsLoaded(locations: locations,reachedMax: true));
  /*  if (reset) resetPagination();

    if (!reachedMax || locations.isEmpty) {
      if (locations.isEmpty) emit(LocationsLoading());

      searchQuery = query ?? searchQuery;

      final response = await repository.getLocations(
        PaginationOptions(

          limit: pageSize,
          page: page,
          search: searchQuery,
        ),
      );
      response.fold(
            (l) {
          emit(LocationsError( message: l.message));
        },
            (data) {
          *//* reachedMax = data.length < pageSize;
          if (!reachedMax) page++;

          universities.addAll(data);*//*
          locations = data;
          emit(LocationsLoaded(
            locations: locations,
            reachedMax: reachedMax,
          ));
        },
      );

    }*/
  }

  addLocation(LocationModel location) {
    location.id = locations.length.toString();
    location.lat = '30.0444';
    location.lng = '31.2357';
    print('sdsa ${location.governance?.name} ${location.city?.name}');
    locations.insert(0,location);
    emit(LocationsLoaded(locations: locations,reachedMax: true));
  }

  deleteLocation(LocationModel location) {
    locations.removeWhere((element) =>  element.id == location.id,);
    emit(LocationsLoaded(locations: locations,reachedMax: true));
  }

  updateLocation(LocationModel location) {
    locations.removeWhere((element) =>  element.id == location.id,);
    locations.insert(0,location);
    emit(LocationsLoaded(locations: locations,reachedMax: true));
  }
}
