import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


import 'config/routes/app_router.dart';
import 'config/themes/theme.dart';

import 'core/widgets/bottom_nav_bar/cubit/bottom_navigation_cubit.dart';

class TaalaApp extends StatefulWidget {
  final AppRouter appRouter;

  const TaalaApp({super.key, required this.appRouter});

  @override
  State<TaalaApp> createState() => _TaalaAppState();
}

class _TaalaAppState extends State<TaalaApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
