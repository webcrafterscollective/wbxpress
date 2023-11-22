import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wbxpress/views/category_view.dart';
import 'package:wbxpress/views/home_view.dart';
import 'package:wbxpress/views/post_content_view.dart';
import 'package:wbxpress/views/new_post_view.dart';

import 'providers/category_provider.dart';

final _router = GoRouter(routes: [
  GoRoute(
    path: '/',
    pageBuilder: (BuildContext context, GoRouterState state) {
      return CustomTransitionPage<void>(
        key: state.pageKey,
        child: const HomeView(),
        barrierDismissible: true,
        barrierColor: Colors.black38,
        opaque: true,
        transitionDuration: const Duration(milliseconds: 500),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        transitionsBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation, Widget child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: Offset.zero, // Start off-screen to the right
              end: Offset.zero, // End at the original position
            ).animate(animation),
            child: child,
          );
        },
      );
    },
    routes: [
      GoRoute(
        path: 'category',
        pageBuilder: (BuildContext context, GoRouterState state) {
          return CustomTransitionPage<void>(
            key: state.pageKey,
            child: const CategoryView(),
            barrierDismissible: true,
            barrierColor: Colors.black38,
            opaque: true,
            transitionDuration: const Duration(milliseconds: 500),
            reverseTransitionDuration: const Duration(milliseconds: 200),
            transitionsBuilder: (BuildContext context,
                Animation<double> animation,
                Animation<double> secondaryAnimation,
                Widget child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: Offset.zero, // Start off-screen to the right
                  end: Offset.zero, // End at the original position
                ).animate(animation),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: 'post',
        pageBuilder: (BuildContext context, GoRouterState state) {
          return CustomTransitionPage<void>(
            key: state.pageKey,
            child: const PostView(),
            barrierDismissible: true,
            barrierColor: Colors.black38,
            opaque: false,
            transitionDuration: const Duration(milliseconds: 500),
            reverseTransitionDuration: const Duration(milliseconds: 200),
            transitionsBuilder: (BuildContext context,
                Animation<double> animation,
                Animation<double> secondaryAnimation,
                Widget child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: Offset.zero, // Start off-screen to the right
                  end: Offset.zero, // End at the original position
                ).animate(animation),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: 'post-content',
        pageBuilder: (BuildContext context, GoRouterState state) {
          return CustomTransitionPage<void>(
            key: state.pageKey,
            child: const PostContentView(),
            barrierDismissible: true,
            barrierColor: Colors.black38,
            opaque: false,
            transitionDuration: const Duration(milliseconds: 500),
            reverseTransitionDuration: const Duration(milliseconds: 200),
            transitionsBuilder: (BuildContext context,
                Animation<double> animation,
                Animation<double> secondaryAnimation,
                Widget child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: Offset.zero, // Start off-screen to the right
                  end: Offset.zero, // End at the original position
                ).animate(animation),
                child: child,
              );
            },
          );
        },
      ),
    ],
  ),
]);

void main(List<String> args) {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CategoryProvider(),
      child: const Wbxpress(),
    ),
  );
}

class Wbxpress extends StatelessWidget {
  const Wbxpress({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Wbxpress',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      routerConfig: _router,
    );
  }
}
