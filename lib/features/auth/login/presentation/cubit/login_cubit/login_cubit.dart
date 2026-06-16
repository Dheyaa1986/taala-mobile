import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../../../core/alerts/alert_delivery_bootstrap.dart';
import '../../../../../../core/app_config/prefs_keys.dart';
import '../../../../../../core/alerts/app_alert_monitor.dart';
import '../../../../../../core/di/service_locator.dart';
import '../../../../../../core/helpers/shared_pref_local_storage.dart';
import '../../../../../../core/helpers/secure_local_storage.dart';
import '../../../data/model/request/login_request_options.dart';
import '../../../data/model/response/user_model.dart';
import 'package:taal/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:taal/features/profile/presentation/cubit/profile_cubit.dart';
import '../../../data/repositories/login_repository.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this.loginRepository) : super(LoginInitial());
  final LoginRepository loginRepository;

  Future<void> login({
    required String email,
    required String password,
    bool isProvider = false,
    bool rememberMe = true,
  }) async {
    emit(LoginLoading());

    final result = await loginRepository.login(
      model: LoginOptions(email: email, password: password),
      isProvider: isProvider,
    );

    result.fold(
      (failure) {
        final isRoleMismatch =
            failure.message.contains('للدخول كـ');
        if (failure.code == 403 && !isRoleMismatch) {
          emit(AccountNotVerified(mailOrPhone: email, error: failure.message));
        } else {
          emit(LoginError(failure.message));
        }
      },
      (response) async {
        await getIt<SharedPref>().set(
          key: PrefsKeys.isProviderAccount,
          value: isProvider,
        );
        await SecureLocalStorage.write(PrefsKeys.token, response.token);
        await SecureLocalStorage.write(
            PrefsKeys.refreshToken, response.refreshToken);
        await getIt<SharedPref>().set(
          key: PrefsKeys.rememberMe,
          value: rememberMe,
        );
        if (rememberMe) {
          await SecureLocalStorage.write(PrefsKeys.mailOrPhone, email);
          await SecureLocalStorage.write(PrefsKeys.password, password);
        } else {
          await SecureLocalStorage.delete(PrefsKeys.mailOrPhone);
          await SecureLocalStorage.delete(PrefsKeys.password);
        }
        await getIt<ProfileCubit>().loadProfile();
        await getIt<NotificationCubit>().refreshInbox(reloadList: true);
        getIt<AppAlertMonitor>().start();
        await AlertDeliveryBootstrap.ensureReady();

        emit(LoginSuccess(response: response));
      },
    );
  }

  toggleRememberMe(bool value) =>
      getIt<SharedPref>().set(key: PrefsKeys.rememberMe, value: value);
}
