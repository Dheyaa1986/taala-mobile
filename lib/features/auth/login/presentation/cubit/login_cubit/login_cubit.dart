import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../../../core/alerts/alert_delivery_bootstrap.dart';
import '../../../../../../core/alerts/notification_router.dart';
import '../../../../../../core/alerts/push_notification_service.dart';
import '../../../../../../core/app_config/prefs_keys.dart';
import '../../../../../../core/alerts/app_alert_monitor.dart';
import '../../../../../../core/di/service_locator.dart';
import '../../../../../../core/helpers/guest_session_helper.dart';
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
  }) async {
    if (state is LoginLoading) return;
    emit(LoginLoading());

    final result = await loginRepository.login(
      model: LoginOptions(email: email, password: password),
      isProvider: isProvider,
    );

    await result.fold<Future<void>>(
      (failure) async {
        final isRoleMismatch = failure.message.contains('للدخول كـ');
        if (failure.code == 403 && !isRoleMismatch) {
          emit(AccountNotVerified(mailOrPhone: email, error: failure.message));
        } else {
          emit(LoginError(failure.message));
        }
      },
      (response) => _establishSession(
        response: response,
        isProvider: isProvider,
        identifier: email,
      ),
    );
  }

  Future<void> loginClientByPhone({required String phone}) async {
    if (state is LoginLoading) return;
    emit(LoginLoading());

    final result = await loginRepository.loginClientByPhone(phone);

    await result.fold<Future<void>>(
      (failure) async => emit(LoginError(failure.message)),
      (response) => _establishSession(
        response: response,
        isProvider: false,
        identifier: phone,
      ),
    );
  }

  Future<void> loginWithPhone({
    required String phone,
    String? otp,
  }) async {
    if (state is LoginLoading) return;
    emit(LoginLoading());

    final result = await loginRepository.verifyClientOtp(
      phone: phone,
      otp: otp,
    );

    await result.fold<Future<void>>(
      (failure) async => emit(LoginError(failure.message)),
      (response) => _establishSession(
        response: response,
        isProvider: false,
        identifier: phone,
      ),
    );
  }

  Future<void> _establishSession({
    required LoginResponseModel response,
    required bool isProvider,
    required String identifier,
  }) async {
    await getIt<SharedPref>().set(
      key: PrefsKeys.isProviderAccount,
      value: isProvider,
    );
    await SecureLocalStorage.write(PrefsKeys.token, response.token);
    await SecureLocalStorage.write(
      PrefsKeys.refreshToken,
      response.refreshToken,
    );
    await SecureLocalStorage.write(PrefsKeys.mailOrPhone, identifier);
    await SecureLocalStorage.delete(PrefsKeys.password);
    await GuestSessionHelper.clearGuestBrowsing();
    if (!isClosed) {
      emit(LoginSuccess(response: response));
    }
    unawaited(_runPostLoginSideEffects());
  }

  Future<void> _runPostLoginSideEffects() async {
    try {
      await getIt<ProfileCubit>().loadProfile();
      await getIt<NotificationCubit>().refreshInbox(reloadList: true);
      getIt<AppAlertMonitor>().start();
      await AlertDeliveryBootstrap.ensureReady();
      await PushNotificationService.instance.processLaunchNotifications();
      await NotificationRouter.processPendingIfAny();
    } catch (_) {}
  }

  Future<({String? debugOtp, String? error})> sendClientOtp(String phone) async {
    final result = await loginRepository.sendClientOtp(phone);
    return result.fold(
      (failure) => (debugOtp: null, error: failure.message),
      (debugOtp) => (debugOtp: debugOtp, error: null),
    );
  }
}
