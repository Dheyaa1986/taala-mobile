import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'config/routes/app_router.dart';
import 'config/themes/theme.dart';
import 'core/alerts/alert_delivery_bootstrap.dart';
import 'core/alerts/app_alert_monitor.dart';
import 'core/app_config/prefs_keys.dart';
import 'core/di/service_locator.dart';
import 'core/helpers/secure_local_storage.dart';
import 'core/widgets/bottom_nav_bar/cubit/bottom_navigation_cubit.dart';
import 'features/notifications/presentation/cubit/notification_cubit.dart';
import 'features/profile/presentation/cubit/profile_cubit.dart';
import 'core/widgets/occasion_banner_shell.dart';
import 'features/theme/presentation/cubit/theme_cubit.dart';

class TaalaApp extends StatefulWidget {
  final AppRouter appRouter;

  const TaalaApp({super.key, required this.appRouter});

  @override
  State<TaalaApp> createState() => _TaalaAppState();
}

class _TaalaAppState extends State<TaalaApp> with WidgetsBindingObserver {
  bool _isCheckingAuth = true;
  String? _initialRoute;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getIt<ThemeCubit>().loadActiveTheme();
    _checkAuthStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      getIt<ThemeCubit>().loadActiveTheme();
      AlertDeliveryBootstrap.ensureReady();
      SecureLocalStorage.read(PrefsKeys.token).then((token) {
        if (token != null && token.isNotEmpty) {
          getIt<NotificationCubit>().refreshInbox(reloadList: true);
        }
      });
    }
  }

  void _scheduleThemeLoad() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      getIt<ThemeCubit>().loadActiveTheme();
    });
  }

  Future<void> _checkAuthStatus() async {
    final token = await SecureLocalStorage.read(PrefsKeys.token);

    setState(() {
      _isCheckingAuth = false;
      if (token != null && token.isNotEmpty) {
        _initialRoute = '/home';
      } else {
        _initialRoute = '/login';
      }
    });
    _scheduleThemeLoad();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AlertDeliveryBootstrap.ensureReady();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAuth) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      fontSizeResolver: (fontSize, screenUtil) {
        return fontSize * screenUtil.scaleWidth.clamp(.8, 1);
      },
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => BottomNavigationCubit(),
            ),
            BlocProvider.value(
              value: getIt<ThemeCubit>(),
            ),
            BlocProvider(
              create: (context) {
                final cubit = getIt<ProfileCubit>();
                SecureLocalStorage.read(PrefsKeys.token).then((token) {
                  if (token != null && token.isNotEmpty) {
                    cubit.loadProfile();
                    getIt<NotificationCubit>().refreshInbox(reloadList: true);
                    getIt<AppAlertMonitor>().start();
                  }
                });
                return cubit;
              },
            ),
            BlocProvider(
              create: (context) => getIt<NotificationCubit>(),
            ),
          ],
          child: GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: BlocBuilder<ThemeCubit, ThemeState>(
              builder: (context, state) {
                return MaterialApp.router(
                  routerConfig: AppRouter.router,
                  theme: TariqyAppTheme.getLightTheme(),
                  debugShowCheckedModeBanner: false,
                  locale: context.locale,
                  supportedLocales: context.supportedLocales,
                  localizationsDelegates: context.localizationDelegates,
                  title: 'taal',
                  builder: (context, child) {
                    return OccasionBannerShell(
                      child: child ?? const SizedBox.shrink(),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
