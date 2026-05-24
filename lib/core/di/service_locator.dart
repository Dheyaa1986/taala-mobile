
import 'package:get_it/get_it.dart';
import 'package:taal/core/countries/data/repository/countries_repo_impl.dart';
import 'package:taal/core/countries/data/repository/countries_repository.dart';
import 'package:taal/core/countries/presentation/cubit/countries_cubit.dart';
import 'package:taal/core/custom_launcher/custom_launcher.dart';
import 'package:taal/features/home/client/data/repository/providers_repository.dart';
import 'package:taal/features/home/client/data/repository/providers_repository_impl.dart';
import 'package:taal/features/home/client/presentation/cubit/service_providers_cubit.dart';
import 'package:taal/features/home/provider/data/repository/locations_repository.dart';
import 'package:taal/features/home/provider/data/repository/locations_repository_impl.dart';
import 'package:taal/features/home/provider/presentation/cubit/locations/location_cubit.dart';
import 'package:taal/features/rating/client/data/repository/providers_repository.dart';
import 'package:taal/features/rating/client/data/repository/providers_repository_impl.dart';
import 'package:taal/features/rating/client/presentation/cubit/client_ratings_cubit.dart';


import '../../features/auth/login/data/repositories/login_repository.dart';
import '../../features/auth/login/data/repositories/login_repository_impl.dart';
import '../../features/auth/login/presentation/cubit/login_cubit/login_cubit.dart';
import '../../features/auth/register/data/repository/register_repository.dart';
import '../../features/auth/register/data/repository/register_repository_impl.dart';
import '../../features/auth/register/presentation/cubit/register_cubit.dart';
import '../countries/data/services/countries_services.dart';
import '../helpers/shared_pref_local_storage.dart';
import '../network/dio_service.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  _initExternals();

  _initRemoteDataSources();
  _initRepositories();
  _initCubits();
}

//?Externals
void _initExternals() async {
  await SharedPref.init();

  getIt.registerLazySingleton<SharedPref>(() => SharedPref());
  getIt.registerLazySingleton<CustomLauncher>(() => CustomLauncher());
  getIt.registerLazySingleton<DioService>(() => DioService());

}

//?Remote Sources
void _initRemoteDataSources() {
  //*countries
  getIt.registerLazySingleton<CountryService>(() => CountryService());
}

//?Repositories
void _initRepositories() {
  //*Auth
  getIt.registerLazySingleton<LoginRepository>(() => LoginRepositoryImpl());

  getIt.registerLazySingleton<RegisterRepository>(
      () => RegisterRepositoryImpl());
  getIt.registerLazySingleton<LocationsRepository>(
          () => LocationsRepositoryImpl());
  getIt.registerLazySingleton<ProviderRepository>(
          () => ProvidersRepositoryImpl());
  getIt.registerLazySingleton<ClientRatingsRepository>(
          () => ClientRatingsRepositoryImpl());
  getIt.registerLazySingleton<CountriesRepository>(
          () => CountriesRepositoryImpl(service: getIt()));
}

//?Blocs

void _initCubits() {
  //*Auth
  getIt.registerFactory<LoginCubit>(
    () => LoginCubit(
      getIt(),
    ),
  );


  getIt.registerFactory<CountriesCubit>(
        () => CountriesCubit(
      getIt(),
    ),
  );



  getIt.registerFactory<RegisterCubit>(
    () => RegisterCubit(
      getIt(),
    ),
  );

  getIt.registerFactory<LocationCubit>(
        () => LocationCubit(
      getIt(),
    ),
  );
  getIt.registerFactory<ServiceProvidersCubit>(
        () => ServiceProvidersCubit(
          repository: getIt(),
    ),
  );
  getIt.registerFactory<ClientRatingsCubit>(
        () => ClientRatingsCubit(
      repository: getIt(),
    ),
  );
}
