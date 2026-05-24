part of 'register_cubit.dart';

sealed class RegisterState extends Equatable {
  const RegisterState();

  @override
  List<Object?> get props => [];
}

final class RegisterInitialState extends RegisterState {}

final class RegisterLoadingState extends RegisterState {}

final class RegisterSuccessState extends RegisterState {
  final BaseResponseModel response;

  const RegisterSuccessState({required this.response});

  @override
  List<Object?> get props => [response];
}

final class RegisterErrorState extends RegisterState {
  final String error;

  const RegisterErrorState(this.error);

  @override
  List<Object> get props => [error];
}
