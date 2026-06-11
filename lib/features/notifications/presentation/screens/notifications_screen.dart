import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/widgets/appbar/logo_skip_appbar.dart';
import 'package:taal/features/notifications/presentation/cubit/notification_cubit.dart';

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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          context.read<NotificationCubit>().loadUnreadCount();
        }
      },
      child: Scaffold(
      appBar: CustomAppBar.backAppBar(
        title: AppStrings.notifications.tr(),
        actions: [
          TextButton(
            onPressed: () {
              context.read<NotificationCubit>().markAllAsRead();
            },
            child: Text(AppStrings.markAllRead.tr()),
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
              padding: REdgeInsets.all(16),
              itemCount: state.items.length,
              separatorBuilder: (_, __) => 12.height,
              itemBuilder: (context, index) {
                final item = state.items[index];
                return Material(
                  color: item.isRead
                      ? Colors.white
                      : AppColors.primaryColor.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12.r),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      side: BorderSide(
                        color: AppColors.lightGreyDividerColor,
                      ),
                    ),
                    title: Text(
                      item.title,
                      style: TextStyle(
                        fontWeight:
                            item.isRead ? FontWeight.w400 : FontWeight.w700,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        6.height,
                        Text(item.message),
                        if (item.createdAt != null) ...[
                          6.height,
                          Text(
                            DateFormat.yMMMd().add_jm().format(item.createdAt!),
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.greyText,
                            ),
                          ),
                        ],
                      ],
                    ),
                    onTap: () {
                      if (!item.isRead) {
                        context.read<NotificationCubit>().markAsRead(item.id);
                      }
                    },
                  ),
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
