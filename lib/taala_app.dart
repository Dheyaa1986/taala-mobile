import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'config/routes/app_router.dart';
import 'config/themes/theme.dart';
import 'core/app_config/prefs_keys.dart';
import 'core/helpers/secure_local_storage.dart';
import 'core/widgets/bottom_nav_bar/cubit/bottom_navigation_cubit.dart';

class TaalaApp extends StatefulWidget {
  final AppRouter appRouter;

  const TaalaApp({super.key, required this.appRouter});

  @override
  State<TaalaApp> createState() => _TaalaAppState();
}

class _TaalaAppState extends State<TaalaApp> {
  bool _isCheckingAuth = true;
  String? _initialRoute;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
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
          ],
          child: GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: MaterialApp.router(
              routerConfig: AppRouter.router,
              theme: TariqyAppTheme.lightTheme,
              debugShowCheckedModeBanner: false,
              locale: context.locale,
              supportedLocales: context.supportedLocales,
              localizationsDelegates: context.localizationDelegates,
              title: 'Taala',
            ),
          ),
        );
      },
    );
  }
}
