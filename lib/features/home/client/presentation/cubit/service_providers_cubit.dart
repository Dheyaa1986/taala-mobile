import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/options/pagination_options.dart';
import 'package:taal/features/home/client/data/repository/providers_repository.dart';
import 'package:taal/features/profile/data/repository/profile_repository.dart';

import '../../data/model/service_provider_model/service_provider_model.dart';

part 'service_providers_state.dart';

class ServiceProvidersCubit extends Cubit<ServiceProvidersState> {
  ServiceProvidersCubit({required this.repository})
      : super(ServiceProvidersInitial());

  final ProviderRepository repository;

  int page = 1;
  final int pageSize = 10;
  bool reachedMax = false;
  List<ServiceProviderModel> providers = [];
  String searchQuery = '';
  ValueNotifier<FilterProvidersModel> filter =
      ValueNotifier(FilterProvidersModel());
  String? _clientId;

  void resetPagination() {
    providers = [];
    page = 1;
    reachedMax = false;
  }

  Future<String?> _resolveClientId() async {
    if (_clientId != null) return _clientId;
    final result = await getIt<ProfileRepository>().getMyProfile();
    return result.fold((_) => null, (profile) {
      _clientId = profile.id;
      return _clientId;
    });
  }

  Future<void> getProviders({
    bool reset = false,
    String? query,
  }) async {
    emit(ServiceProvidersLoading());
    final clientId = await _resolveClientId();
    if (clientId == null) {
      emit(ServiceProvidersError(error: 'Failed to load client profile'));
      return;
    }

    if (reset) {
      resetPagination();
    }

    if (query != null) {
      searchQuery = query;
    }

    final result = await repository.getProviders(
      clientId: clientId,
      options: ProvidersPaginationOptions(
        page: page,
        limit: pageSize,
        search: searchQuery.isEmpty ? null : searchQuery,
        filter: filter.value,
      ),
    );

    result.fold(
      (error) => emit(ServiceProvidersError(error: error.message)),
      (items) {
        providers = reset ? items : [...providers, ...items];
        reachedMax = items.length < pageSize;
        emit(ServiceProvidersLoaded(
          serviceProviders: providers,
          reachedMax: reachedMax,
        ));
      },
    );
  }

  void updateFilter(FilterProvidersModel newFilter) {
    filter.value = newFilter;
    getProviders(reset: true);
  }

  Future<void> loadNearestAvailable({
    required double latitude,
    required double longitude,
  }) async {
    emit(ServiceProvidersLoading());
    final clientId = await _resolveClientId();
    if (clientId == null) {
      emit(ServiceProvidersError(error: 'Failed to load client profile'));
      return;
    }

    resetPagination();
    filter.value = FilterProvidersModel(active: true);

    final result = await repository.getProviders(
      clientId: clientId,
      options: ProvidersPaginationOptions(
        page: page,
        limit: pageSize,
        filter: filter.value,
        clientLatitude: latitude,
        clientLongitude: longitude,
      ),
    );

    result.fold(
      (error) => emit(ServiceProvidersError(error: error.message)),
      (items) {
        providers = items;
        reachedMax = true;
        emit(ServiceProvidersLoaded(
          serviceProviders: providers,
          reachedMax: reachedMax,
        ));
      },
    );
  }
}
