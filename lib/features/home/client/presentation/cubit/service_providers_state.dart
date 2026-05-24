part of 'service_providers_cubit.dart';

@immutable
sealed class ServiceProvidersState {}

final class ServiceProvidersInitial extends ServiceProvidersState {}
final class ServiceProvidersLoading extends ServiceProvidersState {}
final class ServiceProvidersLoaded extends ServiceProvidersState {
  final List<ServiceProviderModel> serviceProviders;
  final bool reachedMax;
  ServiceProvidersLoaded({required this.serviceProviders, required this.reachedMax});
}
final class ServiceProvidersError extends ServiceProvidersState {
  final String error;
  ServiceProvidersError({required this.error});
}
final class ServiceProvidersEmpty extends ServiceProvidersState {}
