import 'package:bot_toast/bot_toast.dart';
import 'package:equiresolve/features/auth/login.dart';
import 'package:equiresolve/features/auth/user_auth.dart';
import 'package:equiresolve/features/home/home.dart';
import 'package:equiresolve/features/intro/splash_screen.dart';
import 'package:equiresolve/router/route_names.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    observers: [BotToastNavigatorObserver()],
    // navigatorKey: appNavigatorKey,
    initialLocation: '/',
    errorBuilder: (context, state) => const SizedBox(
      child: Text('Error'),
    ),
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        name: NamedRoutes.splash.name,
        builder: (BuildContext context, GoRouterState state) {
          return const SplashScreen(
            key: Key('splash-screen-route'),
          );
        },
      ),
      GoRoute(
        path: '/login',
        name: NamedRoutes.signIn.name,
        builder: (BuildContext context, GoRouterState state) {
          return const IntroScreen(
            key: Key('login-screen-route'),
          );
        },
      ),
      GoRoute(
        path: '/auth',
        name: NamedRoutes.userAuth.name,
        builder: (BuildContext context, GoRouterState state) {
          return const UserAuth(
            key: Key('auth-screen-route'),
          );
        },
      ),
      GoRoute(
        path: '/home',
        name: NamedRoutes.homePage.name,
        builder: (BuildContext context, GoRouterState state) {
          return const HomePage(
            key: Key('home-screen-route'),
          );
        },
      ),
    ],
  );
}
