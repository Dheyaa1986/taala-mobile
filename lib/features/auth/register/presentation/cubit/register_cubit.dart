import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:async';
import '../../../../../core/di/service_locator.dart';
import '../../../../../core/maps/offline/map_offline_manager.dart';
import '../../../../../core/helpers/shared_pref_local_storage.dart';
import '../../../../../core/models/base_response_model.dart';
import '../../data/model/register_options.dart';
import '../../data/repository/register_repository.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final RegisterRepository signupRepository;

  RegisterCubit(this.signupRepository) : super(RegisterInitialState());

  Future<void> registerClient({required RegisterOptions options}) async {
    emit(RegisterLoadingState());

    final result = await signupRepository.registerClient(model: options);

    result.fold(
      (failure) => emit(
        RegisterErrorState(
          failure.message,
        ),
      ),
      (response) => emit(
        RegisterSuccessState(
          response: response,
        ),
      ),
    );

    result.fold((_) {}, (_) {
      unawaited(getIt<MapOfflineManager>().syncWhenOnline());
    });
  }


}
