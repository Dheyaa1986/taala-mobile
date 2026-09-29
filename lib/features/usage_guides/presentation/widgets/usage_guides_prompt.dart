import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/config/routes/routes.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/helpers/shared_pref_local_storage.dart';
import 'package:taal/features/usage_guides/data/repository/usage_guides_repository.dart';
import 'package:taal/features/usage_guides/presentation/utils/usage_guides_prefs.dart';

Future<void> maybeShowUsageGuidesPrompt(BuildContext context) async {
  if (!context.mounted) return;

  final repository = getIt<UsageGuidesRepository>();
  final result = await repository.fetchGuides();
  if (!context.mounted) return;

  await result.fold(
    (_) async {},
    (data) async {
      if (data.items.isEmpty) return;

      final prefs = getIt<SharedPref>();
      final seenRevision = await UsageGuidesPrefs.readRevision(prefs);
      if (data.revision <= seenRevision) return;
      if (!context.mounted) return;

      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(AppStrings.usageGuidesPromptTitle.tr()),
          content: Text(AppStrings.usageGuidesPromptBody.tr()),
          actions: [
            TextButton(
              onPressed: () async {
                await UsageGuidesPrefs.saveRevision(prefs, data.revision);
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
              child: Text(AppStrings.usageGuidesLater.tr()),
            ),
            FilledButton(
              onPressed: () async {
                await UsageGuidesPrefs.saveRevision(prefs, data.revision);
                if (!dialogContext.mounted) return;
                Navigator.of(dialogContext).pop();
                if (context.mounted) {
                  context.pushNamed(Routes.usageGuides);
                }
              },
              child: Text(AppStrings.usageGuidesOpen.tr()),
            ),
          ],
        ),
      );
    },
  );
}
