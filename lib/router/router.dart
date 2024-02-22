import 'package:bot_toast/bot_toast.dart';
import 'package:equiresolve/features/intro/splash_screen.dart';
import 'package:equiresolve/router/route_names.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter{
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
        path: '/intro',
        name: NamedRoutes.intro.name,
        builder: (BuildContext context, GoRouterState state) {
          return const SplashScreen(
            key: Key('splash-screen-route'),
          );
        },
      ),
      
    ],
  );

}