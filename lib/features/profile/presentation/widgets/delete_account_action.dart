import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/network/dio_service.dart';
import 'package:taal/features/profile/data/repository/profile_repository.dart';

Future<void> confirmDeleteAccount(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(AppStrings.deleteAccount.tr()),
      content: Text(AppStrings.deleteAccountConfirm.tr()),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(AppStrings.cancel.tr()),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(
            AppStrings.deleteAccount.tr(),
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  );

  if (confirmed != true || !context.mounted) return;

  EasyLoading.show(status: AppStrings.loading.tr());
  final result = await getIt<ProfileRepository>().deleteMyAccount();
  EasyLoading.dismiss();

  if (!context.mounted) return;

  final error = result.fold((e) => e.message, (_) => null);
  if (error != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error)),
    );
    return;
  }

  await getIt<DioService>().logout();
}
