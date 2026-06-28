import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:taal/features/home/client/data/model/service_provider_model/service_provider_model.dart';
import 'package:taal/features/profile/data/repository/profile_repository.dart';

part 'provider_profile_state.dart';

class ProviderProfileCubit extends Cubit<ProviderProfileState> {
  ProviderProfileCubit(this._repository) : super(ProviderProfileInitial());

  final ProfileRepository _repository;
  String? _targetId;
  String? _currentUserId;
  bool _isProviderAccount = false;

  Future<void> load({
    String? providerId,
    required String? currentUserId,
    required bool isProviderAccount,
  }) async {
    _currentUserId = currentUserId;
    _isProviderAccount = isProviderAccount;

    if (providerId != null && providerId.isNotEmpty) {
      _targetId = providerId;
    } else if (currentUserId != null && currentUserId.isNotEmpty) {
      _targetId = currentUserId;
    } else {
      emit(ProviderProfileError('Provider not found'));
      return;
    }

    emit(ProviderProfileLoading());
    final result = await _repository.getProviderProfile(_targetId!);
    result.fold(
      (error) => emit(ProviderProfileError(error.message)),
      (provider) => emit(
        ProviderProfileLoaded(
          provider: provider,
          isOwnProfile: _isOwnProfile,
          showProviderTools: _showProviderTools,
        ),
      ),
    );
  }

  Future<void> refresh() async {
    if (_targetId == null) return;
    final current = state;
    if (current is ProviderProfileLoaded) {
      emit(ProviderProfileRefreshing(
        provider: current.provider,
        isOwnProfile: current.isOwnProfile,
        showProviderTools: current.showProviderTools,
      ));
    }

    final result = await _repository.getProviderProfile(_targetId!);
    result.fold(
      (error) => emit(ProviderProfileError(error.message)),
      (provider) => emit(
        ProviderProfileLoaded(
          provider: provider,
          isOwnProfile: _isOwnProfile,
          showProviderTools: _showProviderTools,
        ),
      ),
    );
  }

  Future<String?> createPortfolio({
    required String description,
    required List<File> images,
  }) async {
    final result = await _repository.createPortfolio(
      description: description,
      images: images,
    );
    return result.fold(
      (error) => error.message,
      (_) {
        refresh();
        return null;
      },
    );
  }

  Future<String?> deletePortfolio(String portfolioId) async {
    final result = await _repository.deletePortfolio(portfolioId);
    return result.fold(
      (error) => error.message,
      (_) {
        refresh();
        return null;
      },
    );
  }

  bool get _isOwnProfile =>
      _currentUserId != null &&
      _targetId != null &&
      _currentUserId == _targetId;

  bool get _showProviderTools => _isProviderAccount && _isOwnProfile;
}
