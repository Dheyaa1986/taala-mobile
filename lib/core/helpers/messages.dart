import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/extensions/space_extension.dart';

import '../app_config/app_colors.dart';

class AppMessages {
  static BuildContext? _loadingDialogContext;
  static bool _hideWhenReady = false;

  static Future<dynamic> showLoading(BuildContext context) {
    _hideWhenReady = false;
    return showDialog<dynamic>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (dialogContext) {
        _loadingDialogContext = dialogContext;
        if (_hideWhenReady) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            hideLoading();
          });
        }
        return const PopScope(
          canPop: false,
          child: Center(
            child: CircularProgressIndicator.adaptive(),
          ),
        );
      },
    ).whenComplete(() {
      _loadingDialogContext = null;
    });
  }

  static void hideLoading([BuildContext? context]) {
    _hideWhenReady = true;
    final dialogContext = _loadingDialogContext;
    if (dialogContext == null || !dialogContext.mounted) return;
    _loadingDialogContext = null;
    Navigator.of(dialogContext).pop();
  }

  static void showError(BuildContext context, String error,
      [SnackBarAction? action]) {
    _showSnack(context, error, isError: true, action: action);
  }

  static void showSuccess(BuildContext context, String message,
      [SnackBarAction? action]) {
    _showSnack(context, message, isError: false, action: action);
  }

  static void _showSnack(
    BuildContext context,
    String text, {
    required bool isError,
    SnackBarAction? action,
  }) {
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.r)),
          side: const BorderSide(
            color: AppColors.borderColor,
          ),
        ),
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_sharp : Icons.check_circle,
              color: isError ? AppColors.errorColor : AppColors.green,
            ),
            8.width,
            Flexible(
              child: Text(
                text,
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ),
        action: action,
      ),
    );
  }
}
