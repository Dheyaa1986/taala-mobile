import 'package:get_it/get_it.dart';
import 'package:taal/core/maps/device_location_service.dart';
import 'package:taal/core/maps/provider_live_location_service.dart';
import 'package:taal/core/maps/reverse_geocoding_service.dart';
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


import '../../features/notifications/data/repository/notification_repository.dart';
import '../../features/theme/data/repositories/theme_repository.dart';
import '../../features/theme/data/repositories/theme_repository_impl.dart';
import '../../features/theme/presentation/cubit/theme_cubit.dart';
import '../../features/support/data/repository/support_ticket_repository.dart';
import '../../features/support/presentation/cubit/support_ticket_cubit.dart';
import '../../features/notifications/presentation/cubit/notification_cubit.dart';
import '../../features/profile/data/repository/profile_repository.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
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
  await _initExternals();

  _initRemoteDataSources();
  _initRepositories();
  _initCubits();
}

Future<void> _initExternals() async {
  await SharedPref.init();

  getIt.registerLazySingleton<SharedPref>(() => SharedPref());
  getIt.registerLazySingleton<CustomLauncher>(() => CustomLauncher());
  getIt.registerLazySingleton<DioService>(() => DioService());
  getIt.registerLazySingleton<DeviceLocationService>(
    () => DeviceLocationService(),
  );
  getIt.registerLazySingleton<ReverseGeocodingService>(
    () => ReverseGeocodingService(),
  );
  getIt.registerLazySingleton<ProviderLiveLocationService>(
    () => ProviderLiveLocationService(),
  );

}

void _initRemoteDataSources() {
  getIt.registerLazySingleton<CountryService>(() => CountryService());
}

void _initRepositories() {
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
  getIt.registerLazySingleton<ProfileRepository>(() => ProfileRepository());
  getIt.registerLazySingleton<NotificationRepository>(
      () => NotificationRepository());
  getIt.registerLazySingleton<SupportTicketRepository>(
      () => SupportTicketRepository());
  getIt.registerLazySingleton<ThemeRepository>(() => ThemeRepositoryImpl());
}

void _initCubits() {
  getIt.registerFactory<LoginCubit>(
    () => LoginCubit(
      getIt(),
    ),
  );

  getIt.registerLazySingleton<ProfileCubit>(
    () => ProfileCubit(getIt()),
  );

  getIt.registerLazySingleton<NotificationCubit>(
    () => NotificationCubit(getIt()),
  );

  getIt.registerLazySingleton<ThemeCubit>(
    () => ThemeCubit(getIt()),
  );

  getIt.registerFactory<SupportTicketCubit>(
    () => SupportTicketCubit(getIt()),
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
