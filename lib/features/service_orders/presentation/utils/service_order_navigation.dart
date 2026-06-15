import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/config/routes/app_router.dart';
import 'package:taal/config/routes/routes.dart';

class ServiceOrderNavigation {
  static void openDetail(String orderId, {bool openChat = false}) {
    final context = AppRouter.appNavigatorKey.currentContext;
    if (context == null || orderId.isEmpty) return;

    GoRouter.of(context).pushNamed(
      Routes.serviceOrderDetail,
      pathParameters: {'id': orderId},
      extra: openChat,
    );
  }

  static void closeSheetsThenOpenDetail(
    String orderId, {
    int sheetsToClose = 2,
    bool openChat = false,
  }) {
    final context = AppRouter.appNavigatorKey.currentContext;
    if (context == null || orderId.isEmpty) return;

    final navigator = Navigator.of(context, rootNavigator: true);
    var closed = 0;
    while (navigator.canPop() && closed < sheetsToClose) {
      navigator.pop();
      closed++;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      openDetail(orderId, openChat: openChat);
    });
  }
}
