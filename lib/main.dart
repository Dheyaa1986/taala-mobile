import 'package:easy_localization/easy_localization.dart';
import 'package:taal/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taal/taala_app.dart';

import 'config/locale/locales.dart';
import 'config/routes/app_router.dart';
import 'core/alerts/firebase_background_handler.dart';
import 'core/di/service_locator.dart';
import 'core/helpers/bloc_observer.dart';
import 'core/helpers/locale_helper.dart';
import 'core/package_info_helper/package_info_helper.dart';
import 'core/remote_config_helper/remote_config_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  Bloc.observer = MyBlocObserver();

  await EasyLocalization.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await RemoteConfigHelper.initialize();
  } catch (error) {
    debugPrint('Firebase init failed: $error');
  }
  await PackageInfoHelper.initialize();
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
