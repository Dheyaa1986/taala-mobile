import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/config/routes/routes.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/widgets/appbar/logo_skip_appbar.dart';
import 'package:taal/features/notifications/data/models/notification_model.dart';
import 'package:taal/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:taal/features/notifications/presentation/widgets/notification_card.dart';
import 'package:taal/core/app_config/prefs_keys.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/helpers/shared_pref_local_storage.dart';
import 'package:taal/features/service_orders/presentation/helpers/service_order_local_state_helper.dart';
import 'package:taal/features/service_orders/presentation/utils/service_order_navigation.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationCubit>().loadNotifications();
  }

  void _onNotificationTap(NotificationModel item) async {
    if (!item.isRead) {
      context.read<NotificationCubit>().markAsRead(item.id);
    }

    final orderId = item.linkedServiceOrderId;
    if (orderId != null && orderId.isNotEmpty) {
      final isProvider =
          getIt<SharedPref>().get(key: PrefsKeys.isProviderAccount) == true;
      if (isProvider) {
        await ServiceOrderLocalStateHelper.undismiss(orderId);
        await ServiceOrderLocalStateHelper.markRead(orderId);
      }
      ServiceOrderNavigation.openDetail(orderId, openChat: true);
      return;
    }

    final ticketId = item.supportTicketId;
    if (ticketId != null && ticketId.isNotEmpty) {
      context.pushNamed(
        Routes.supportTicketDetail,
        pathParameters: {'id': ticketId},
      );
    }
  }

  Future<void> _confirmDelete(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.deleteNotification.tr()),
        content: Text(AppStrings.deleteNotificationSubtitle.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppStrings.cancel.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppStrings.delete.tr()),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<NotificationCubit>().deleteNotification(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          context.read<NotificationCubit>().refreshInbox(reloadList: true);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.lightBGColor,
        appBar: CustomAppBar.backAppBar(
          title: AppStrings.notifications.tr(),
          actions: [
            BlocBuilder<NotificationCubit, NotificationState>(
              builder: (context, state) {
                final unread =
                    state is NotificationLoaded ? state.unreadCount : 0;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (unread > 0)
                      Container(
                        margin: REdgeInsets.only(left: 4, right: 4),
                        padding: REdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          '$unread',
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    TextButton(
                      onPressed: unread > 0
                          ? () {
                              context
                                  .read<NotificationCubit>()
                                  .markAllAsRead();
                            }
                          : null,
                      child: Text(
                        AppStrings.markAllRead.tr(),
                        style: TextStyle(
                          color: unread > 0
                              ? AppColors.primaryColor
                              : AppColors.greyText,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<NotificationCubit, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is NotificationError) {
              return Center(child: Text(state.message));
            }

            if (state is NotificationLoaded) {
              if (state.items.isEmpty) {
                return Center(
                  child: Text(
                    AppStrings.noNotifications.tr(),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                );
              }

              return ListView.separated(
                padding: REdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount: state.items.length,
                separatorBuilder: (_, __) => 10.height,
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  return NotificationCard(
                    notification: item,
                    onTap: () => _onNotificationTap(item),
                    onDelete: () => _confirmDelete(item.id),
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
