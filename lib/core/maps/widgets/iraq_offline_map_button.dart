import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/helpers/connectivity_helper.dart';
import 'package:taal/core/helpers/messages.dart';
import 'package:taal/core/maps/offline/map_offline_manager.dart';

class IraqOfflineMapButton extends StatelessWidget {
  const IraqOfflineMapButton({
    super.key,
    this.onDownloaded,
    this.heroTag = 'iraqOfflineMapFab',
    this.iconOnly = false,
  });

  final VoidCallback? onDownloaded;
  final Object heroTag;
  final bool iconOnly;

  Future<void> _download(BuildContext context) async {
    if (!await ConnectivityHelper.connected) {
      if (!context.mounted) return;
      AppMessages.showError(context, AppStrings.offlineIraqNeedInternet.tr());
      return;
    }

    final progress = ValueNotifier<(int, int, String)>((0, 1, ''));
    if (!context.mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(AppStrings.offlineIraqDownloading.tr()),
          content: ValueListenableBuilder<(int, int, String)>(
            valueListenable: progress,
            builder: (context, value, _) {
              final done = value.$1;
              final total = value.$2 <= 0 ? 1 : value.$2;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(value: done / total),
                  SizedBox(height: 12.h),
                  Text(
                    AppStrings.offlineIraqProgress.tr(
                      namedArgs: {
                        'done': '$done',
                        'total': '$total',
                        'name': value.$3,
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );

    try {
      await getIt<MapOfflineManager>().downloadAllIraqMaps(
        onProgress: (done, total, name) {
          progress.value = (done, total, name);
        },
      );
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
      if (context.mounted) {
        AppMessages.showSuccess(context, AppStrings.offlineIraqReady.tr());
      }
      onDownloaded?.call();
    } catch (_) {
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
      if (context.mounted) {
        AppMessages.showError(context, AppStrings.offlineIraqFailed.tr());
      }
    } finally {
      progress.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tooltip = AppStrings.offlineIraqDownload.tr();
    if (iconOnly) {
      return IconButton(
        tooltip: tooltip,
        onPressed: () => _download(context),
        icon: const Icon(Icons.download_for_offline_outlined),
      );
    }
    return FloatingActionButton.small(
      heroTag: heroTag,
      tooltip: tooltip,
      onPressed: () => _download(context),
      child: const Icon(Icons.download_for_offline_outlined),
    );
  }
}
