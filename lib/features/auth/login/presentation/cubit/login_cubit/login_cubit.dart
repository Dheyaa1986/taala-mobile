import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';


import '../../../../../../core/app_config/prefs_keys.dart';
import '../../../../../../core/di/service_locator.dart';
import '../../../../../../core/helpers/shared_pref_local_storage.dart';
import '../../../data/model/request/login_request_options.dart';
import '../../../data/model/response/user_model.dart';
import '../../../data/repositories/login_repository.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this.loginRepository) : super(LoginInitial());
  final LoginRepository loginRepository;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(LoginLoading());
    final result = await loginRepository.login(
        model: LoginOptions(email: email, password: password));
    result.fold(
      (failure) {
        if (failure.code == 403) {
          emit(AccountNotVerified(mailOrPhone: email,error: failure.message));
        } else {
          emit(LoginError(failure.message));
        }
      },
      (user) => emit(
        LoginSuccess(user: user),
      ),
    );
  }

  toggleRememberMe(bool value) =>
      getIt<SharedPref>().set(key: PrefsKeys.rememberMe, value: value);
}
