import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/widgets/appbar/logo_skip_appbar.dart';
import 'package:taal/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:taal/features/notifications/presentation/widgets/notification_card.dart';

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
        backgroundColor: AppColors.lightBGColor,
        appBar: CustomAppBar.backAppBar(
          title: AppStrings.notifications.tr(),
          actions: [
            TextButton(
              onPressed: () {
                context.read<NotificationCubit>().markAllAsRead();
              },
              child: Text(
                AppStrings.markAllRead.tr(),
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.sp,
                ),
              ),
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
                    onTap: () {
                      if (!item.isRead) {
                        context.read<NotificationCubit>().markAsRead(item.id);
                      }
                    },
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
