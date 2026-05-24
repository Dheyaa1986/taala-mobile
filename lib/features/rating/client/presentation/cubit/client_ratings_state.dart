part of 'client_ratings_cubit.dart';

@immutable
sealed class ClientRatingsState {}

final class ClientRatingsInitial extends ClientRatingsState {}
final class ClientRatingsLoading extends ClientRatingsState {}
final class ClientRatingsLoaded extends ClientRatingsState {
  final List<ClientRatingsModel> ratings;
   final bool reachedMax;
  ClientRatingsLoaded({
    required this.ratings,
    required this.reachedMax,
  });
}
final class ClientRatingsError extends ClientRatingsState {
  final String message;
  ClientRatingsError({required this.message});
}
