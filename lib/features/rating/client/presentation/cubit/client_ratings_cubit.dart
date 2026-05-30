import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:meta/meta.dart';
import 'package:taal/features/home/client/data/model/service_provider_model/service_provider_model.dart';
import 'package:taal/features/rating/client/data/model/client_ratings.dart';
import 'package:taal/features/rating/client/data/repository/providers_repository.dart';

import '../../../../home/provider/data/model/governate.dart';
import '../../../../home/provider/data/model/location_model.dart';

part 'client_ratings_state.dart';

class ClientRatingsCubit extends Cubit<ClientRatingsState> {
  ClientRatingsCubit({required this.repository})
      : super(ClientRatingsInitial());

  ClientRatingsRepository repository;

  int page = 1;
  final int pageSize = 10;
  bool reachedMax = false;
  List<ClientRatingsModel> clientRatings = [];
  String searchQuery = '';

  void resetPagination() {
    clientRatings = [];
    page = 1;
    reachedMax = false;
  }

  getClientRatings({
    bool reset = false,
    String? query,
  }) async {
    emit(ClientRatingsLoading());
    Future.delayed(const Duration(seconds: 1));
    clientRatings = List.generate(
      10,
      (index) => ClientRatingsModel(
        date:  DateFormat('dd/MM/yyyy').format(DateTime.now().subtract(Duration(days: index))),
          rating: 4.5,
          comment: 'the service provider $index is good and on time',
          id: index,
          serviceProviderModel: ServiceProviderModel(
            id: index,
            name: 'Provider $index',
            image: 'https://cdn-icons-png.flaticon.com/512/219/219983.png',
            totalRatings: 100,
            rate: 4.5,
            address: 'Alexandria, Nasr City, Downtown',
            lat: '30.0444',
            lng: '31.2357',
            email: 'user$index@email.com',
            phone: '0100000000$index',
            services: ['Cleaning', 'Cooking'],
            locations: [
              LocationModel(
                id: index.toString(),
                governance: GovernanceModel(name: 'Alexandria', id: 3),
                city: CityModel(name: 'Nasr City', id: 101),
                region: RegionModel(name: 'Downtown', id: 1003),
                lat: '30.0444',
                lng: '31.2357',
              ),
            ],
          )),
    );
    emit(ClientRatingsLoaded(ratings: clientRatings, reachedMax: true));
  }
}
