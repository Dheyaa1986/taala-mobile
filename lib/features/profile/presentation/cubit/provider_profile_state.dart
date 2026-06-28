part of 'provider_profile_cubit.dart';

sealed class ProviderProfileState {}

final class ProviderProfileInitial extends ProviderProfileState {}

final class ProviderProfileLoading extends ProviderProfileState {}

final class ProviderProfileRefreshing extends ProviderProfileState {
  ProviderProfileRefreshing({
    required this.provider,
    required this.isOwnProfile,
    required this.showProviderTools,
  });

  final ServiceProviderModel provider;
  final bool isOwnProfile;
  final bool showProviderTools;
}

final class ProviderProfileLoaded extends ProviderProfileState {
  ProviderProfileLoaded({
    required this.provider,
    required this.isOwnProfile,
    required this.showProviderTools,
  });

  final ServiceProviderModel provider;
  final bool isOwnProfile;
  final bool showProviderTools;
}

final class ProviderProfileError extends ProviderProfileState {
  ProviderProfileError(this.message);
  final String message;
}
