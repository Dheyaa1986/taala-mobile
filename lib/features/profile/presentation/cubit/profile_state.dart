part of 'profile_cubit.dart';

sealed class ProfileState {}

final class ProfileInitial extends ProfileState {}

final class ProfileLoading extends ProfileState {}

final class ProfileLoaded extends ProfileState {
  ProfileLoaded(this.profile);
  final UserProfileModel profile;
}

final class ProfileError extends ProfileState {
  ProfileError(this.message);
  final String message;
}

final class ProfileUpdating extends ProfileState {
  ProfileUpdating(this.profile);
  final UserProfileModel profile;
}
