import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/config/routes/routes.dart';
import 'package:taal/config/routes/routing_observer.dart';
import 'package:taal/features/auth/login/presentation/screens/login_screen.dart';
import 'package:taal/features/auth/register/presentation/screens/register_screen.dart';
import 'package:taal/features/home/home_screen.dart';
import 'package:taal/features/profile/client/presentation/screens/client_settings_screen.dart';
import 'package:taal/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:taal/features/profile/presentation/screens/provider_profile_screen.dart';
import 'package:taal/features/profile/settings_screen.dart';
import 'package:taal/features/rating/base_rating_screen.dart';
import 'package:taal/features/rating/client/presentation/screen/client_rating_screen.dart';
import 'package:taal/features/rating/presentation/screens/rating_screen.dart';
import 'package:taal/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:taal/features/splash/splash_screen.dart';
import 'package:taal/features/support/presentation/cubit/support_ticket_cubit.dart';
import 'package:taal/features/support/presentation/screens/support_ticket_detail_screen.dart';
import 'package:taal/features/support/presentation/screens/support_tickets_screen.dart';

import '../../core/di/service_locator.dart';
import '../../core/widgets/bottom_nav_bar/bottom_nav_bar.dart';
import '../../core/widgets/bottom_nav_bar/cubit/bottom_navigation_cubit.dart';
import '../../features/auth/register/data/model/register_options.dart';
import '../../features/auth/select_role/presentation/select_role_screen.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> appNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _homeTabNavigatorKey =
      GlobalKey<NavigatorState>();

  static final GlobalKey<NavigatorState> _rateNavigatorKey =
      GlobalKey<NavigatorState>();

  static final GlobalKey<NavigatorState> _settingsTabNavigatorKey =
      GlobalKey<NavigatorState>();

  static final List<StatefulShellBranch> _homeBranches = [
    StatefulShellBranch(
      navigatorKey: _homeTabNavigatorKey,
      routes: [
        GoRoute(
          path: Routes.home,
          name: Routes.home,
          pageBuilder: (context, state) => screenWithFadeTransition(
            context: context,
            state: state,
            child: HomeScreen(),
          ),
          routes: const [],
        ),
      ],
    ),
  ];

  static final List<StatefulShellBranch> _settingsBranches = [
    StatefulShellBranch(
      navigatorKey: _settingsTabNavigatorKey,
      routes: [
        GoRoute(
          path: Routes.baseSettings,
          name: Routes.baseSettings,
          pageBuilder: (context, state) => screenWithFadeTransition(
            context: context,
            state: state,
            child: const BaseSettingsScreen(),
          ),
        ),
        GoRoute(
          path: Routes.clientSettings,
          name: Routes.clientSettings,
          pageBuilder: (context, state) => screenWithFadeTransition(
            context: context,
            state: state,
            child: const ClientSettingsScreen(),
          ),
        ),
        GoRoute(
          path: Routes.menu,
          name: Routes.menu,
          pageBuilder: (context, state) => screenWithFadeTransition(
            context: context,
            state: state,
            child: ProviderProfileScreen(
              id: state.extra as String?,
            ),
          ),
        ),
        GoRoute(
          path: Routes.editProfile,
          name: Routes.editProfile,
          pageBuilder: (context, state) => screenWithFadeTransition(
            context: context,
            state: state,
            child: const EditProfileScreen(),
          ),
        ),
      ],
    ),
  ];

  static GoRouter router = GoRouter(
      observers: [
        GoRouterObserver(),
      ],
      navigatorKey: appNavigatorKey,
      initialLocation: Routes.splashScreen,
      routes: <RouteBase>[
        StatefulShellRoute.indexedStack(
          parentNavigatorKey: appNavigatorKey,
          pageBuilder: (context, state, navigationShell) {
            context.read<BottomNavigationCubit>().navigationShell =
                navigationShell;
            return screenWithFadeTransition(
              context: context,
              state: state,
              child: BottomNavBar(
                shell: navigationShell,
              ),
            );
          },
          branches: [
            ..._homeBranches,
            ..._rateBranches,
            ..._settingsBranches,
          ],
        ),
        GoRoute(
          parentNavigatorKey: appNavigatorKey,
          path: Routes.splashScreen,
          name: Routes.splashScreen,
          pageBuilder: (context, state) => screenWithFadeTransition(
            context: context,
            state: state,
            child: SplashScreen(
              isProvider: state.extra as bool?,
            ),
          ),
          routes: const [],
        ),
        GoRoute(
          parentNavigatorKey: appNavigatorKey,
          path: Routes.login,
          name: Routes.login,
          pageBuilder: (context, state) => screenWithFadeTransition(
            context: context,
            state: state,
            child: LoginScreen(initialIsProvider: state.extra as bool?),
          ),
          routes: const [],
        ),
        GoRoute(
          parentNavigatorKey: appNavigatorKey,
          path: Routes.clientRatingsScreen,
          name: Routes.clientRatingsScreen,
          pageBuilder: (context, state) => screenWithFadeTransition(
            context: context,
            state: state,
            child: const ClientRatingsScreen(),
          ),
          routes: const [],
        ),
        GoRoute(
          parentNavigatorKey: appNavigatorKey,
          path: Routes.register,
          name: Routes.register,
          pageBuilder: (context, state) => screenWithFadeTransition(
            context: context,
            state: state,
            child: const RegisterScreen(),
          ),
          routes: const [],
        ),
        GoRoute(
          parentNavigatorKey: appNavigatorKey,
          path: Routes.selectRoleScreen,
          name: Routes.selectRoleScreen,
          pageBuilder: (context, state) => screenWithFadeTransition(
            context: context,
            state: state,
            child: SelectRoleScreen(
              options: state.extra as RegisterOptions?,
            ),
          ),
          routes: const [],
        ),
        GoRoute(
          parentNavigatorKey: appNavigatorKey,
          path: Routes.notifications,
          name: Routes.notifications,
          pageBuilder: (context, state) => screenWithFadeTransition(
            context: context,
            state: state,
            child: const NotificationsScreen(),
          ),
        ),
        GoRoute(
          parentNavigatorKey: appNavigatorKey,
          path: Routes.supportTickets,
          name: Routes.supportTickets,
          pageBuilder: (context, state) => screenWithFadeTransition(
            context: context,
            state: state,
            child: BlocProvider(
              create: (_) => getIt<SupportTicketCubit>(),
              child: const SupportTicketsScreen(),
            ),
          ),
          routes: [
            GoRoute(
              parentNavigatorKey: appNavigatorKey,
              path: ':id',
              name: Routes.supportTicketDetail,
              pageBuilder: (context, state) => screenWithFadeTransition(
                context: context,
                state: state,
                child: BlocProvider(
                  create: (_) => getIt<SupportTicketCubit>(),
                  child: SupportTicketDetailScreen(
                    ticketId: state.pathParameters['id']!,
                  ),
                ),
              ),
            ),
          ],
        ),
      ]);
  static List<StatefulShellBranch> get _rateBranches => [
        StatefulShellBranch(
          navigatorKey: _rateNavigatorKey,
          routes: [
            GoRoute(
              path: Routes.baseRate,
              name: Routes.baseRate,
              pageBuilder: (context, state) => screenWithFadeTransition(
                context: context,
                state: state,
                child: const BaseRatingScreen(),
              ),
            ),
            GoRoute(
              path: Routes.rate,
              name: Routes.rate,
              pageBuilder: (context, state) => screenWithFadeTransition(
                context: context,
                state: state,
                child: const RatingScreen(),
              ),
            ),
          ],
        ),
      ];
}

CustomTransitionPage screenWithFadeTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    transitionDuration: const Duration(milliseconds: 300),
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}
