import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/config/routes/routes.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/features/notifications/presentation/cubit/notification_cubit.dart';

class NotificationIconButton extends StatelessWidget {
  const NotificationIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        final unreadCount =
            state is NotificationLoaded ? state.unreadCount : 0;

        return IconButton(
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(minWidth: 40.w, minHeight: 40.w),
          onPressed: () {
            context.pushNamed(Routes.notifications);
          },
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.notifications_outlined,
                color: AppColors.primaryColor,
                size: 24.sp,
              ),
              if (unreadCount > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: EdgeInsets.all(4.r),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16.r,
                      minHeight: 16.r,
                    ),
                    child: Text(
                      unreadCount > 9 ? '9+' : '$unreadCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
