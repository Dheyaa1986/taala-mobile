import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:taal/features/profile/data/models/user_profile_model.dart';
import 'package:taal/features/profile/data/repository/profile_repository.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._repository) : super(ProfileInitial());

  final ProfileRepository _repository;

  Future<void> loadProfile() async {
    emit(ProfileLoading());
    final result = await _repository.getMyProfile();
    result.fold(
      (error) => emit(ProfileError(error.message)),
      (profile) => emit(ProfileLoaded(profile)),
    );
  }

  Future<bool> completeClientRegistration({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? address,
    File? image,
  }) async {
    final current = state;
    if (current is! ProfileLoaded) return false;

    emit(ProfileUpdating(current.profile));
    final result = await _repository.completeClientRegistration(
      userId: current.profile.id,
      name: name,
      email: email,
      phone: phone,
      password: password,
      address: address,
      image: image,
    );

    return result.fold(
      (error) {
        emit(ProfileError(error.message));
        return false;
      },
      (_) {
        loadProfile();
        return true;
      },
    );
  }

  Future<bool> updateProfile({
    required String name,
    File? image,
    required bool isProvider,
    bool completeProfile = false,
  }) async {
    final current = state;
    if (current is! ProfileLoaded) return false;

    emit(ProfileUpdating(current.profile));
    final result = isProvider
        ? await _repository.updateProviderProfile(name: name, image: image)
        : await _repository.updateClientProfile(
            userId: current.profile.id,
            name: name,
            image: image,
            completeProfile: completeProfile,
          );

    return result.fold(
      (error) {
        emit(ProfileError(error.message));
        return false;
      },
      (_) {
        loadProfile();
        return true;
      },
    );
  }
}
