import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taal/taala_app.dart';

import 'config/locale/locales.dart';
import 'config/routes/app_router.dart';
import 'core/di/service_locator.dart';
import 'core/helpers/bloc_observer.dart';
import 'core/helpers/locale_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  Bloc.observer = MyBlocObserver();

  await EasyLocalization.ensureInitialized();
  await setupServiceLocator();
  debugRepaintRainbowEnabled = false;

  runApp(
    EasyLocalization(
      ignorePluralRules: false,
      startLocale: LocaleHelper.savedLocale() ??
          AppLocales.supportedLocales.first,
      supportedLocales: AppLocales.supportedLocales,
      fallbackLocale: AppLocales.supportedLocales.first,
      saveLocale: true,
      path: 'assets/translations',
      child: TaalaApp(
        appRouter: AppRouter(),
      ),
    ),
  );
}
