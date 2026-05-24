import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:taal/core/options/pagination_options.dart';
import 'package:taal/features/home/client/data/repository/providers_repository.dart';
import 'package:taal/features/home/provider/data/model/location_model.dart';

import '../../../provider/data/model/governate.dart';
import '../../data/model/service_provider_model/service_provider_model.dart';

part 'service_providers_state.dart';

class ServiceProvidersCubit extends Cubit<ServiceProvidersState> {
  ServiceProvidersCubit({required this.repository})
      : super(ServiceProvidersInitial());

  ProviderRepository repository;

  int page = 1;
  final int pageSize = 10;
  bool reachedMax = false;
  List<ServiceProviderModel> providers = [];
  String searchQuery = '';
  ValueNotifier<FilterProvidersModel> filter =
      ValueNotifier(FilterProvidersModel());
  void resetPagination() {
    providers = [];
    page = 1;
    reachedMax = false;
  }

  getProviders({
    bool reset = false,
    String? query,
  }) async {
    print(
        'getProviders ${filter.value.active}, ${filter.value.regionId}, ${filter.value.cityId}, ${filter.value.governanceId}, ${filter.value.serviceTypeId}');
    emit(ServiceProvidersLoading());
    Future.delayed(const Duration(seconds: 1));
    providers = List.generate(10, (index) {
      return ServiceProviderModel(
        locations: [
          LocationModel(
            id: '1',
            governance: GovernanceModel(name: 'Alexandria', id: 3),
            city: CityModel(name: 'Nasr City', id: 101),
            region: RegionModel(name: 'Downtown', id: 1003),
            lat: '30.0444',
            lng: '31.2357',
          )
        ],
        totalRatings: index + 1,
        id: index + 1,
        name: 'Provider ${index + 1}',
        rate: (3.5 + index % 3),
        email: 'provider${index + 1}@example.com',
        services: ['Cleaning', 'Plumbing', 'Electrical']
            .sublist(0, (index % 3) + 1), // Varying service count
        phone: '012345678${index}',
        image: 'https://example.com/images/provider${index + 1}.jpg',
        address: 'Street ${index + 1}, City ${index % 3 + 1}',
        lat: '30.${index}1234',
        lng: '31.${index}5678',
      );
    });
    emit(ServiceProvidersLoaded(serviceProviders: providers, reachedMax: true));
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
          */ /* reachedMax = data.length < pageSize;
          if (!reachedMax) page++;

          universities.addAll(data);*/ /*
          locations = data;
          emit(LocationsLoaded(
            locations: locations,
            reachedMax: reachedMax,
          ));
        },
      );

    }*/
  }

  updateFilter(FilterProvidersModel filter) {
    this.filter.value = filter;
    getProviders(reset: true);
  }
}
