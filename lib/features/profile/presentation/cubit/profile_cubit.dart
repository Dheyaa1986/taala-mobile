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
