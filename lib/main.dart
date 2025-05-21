// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' show Platform;
import 'dart:async' show StreamSubscription;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shop_application/common/theme.dart';
import 'package:shop_application/firebase_options.dart';
import 'package:shop_application/models/cart.dart';
import 'package:shop_application/models/catalog.dart';
import 'package:shop_application/screens/cart.dart';
import 'package:shop_application/screens/catalog.dart';
import 'package:shop_application/screens/login.dart';
import 'package:shop_application/services/auth_service.dart';
import 'package:window_size/window_size.dart';

// Custom Listenable for GoRouter to listen to Firebase auth changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Handle sign-in redirect result for web
  if (kIsWeb) {
    try {
      // Get the auth instance
      final auth = FirebaseAuth.instance;

      // Allow Firebase Auth to initialize completely
      await Future.delayed(const Duration(milliseconds: 300));

      // Check for redirect result only if not signed in yet
      if (auth.currentUser == null) {
        try {
          final result = await auth.getRedirectResult();
          if (result.user != null) {
            print("User signed in after redirect: ${result.user!.displayName}");
          }
        } catch (e) {
          if (!e.toString().contains('already-initialized')) {
            print("Error handling redirect result: $e");
          }
        }
      }
    } catch (e) {
      print("Error in Firebase initialization: $e");
    }
  }

  setupWindow();
  runApp(const MyApp());
}

const double windowWidth = 400;
const double windowHeight = 800;

void setupWindow() {
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    WidgetsFlutterBinding.ensureInitialized();
    setWindowTitle('Provider Demo');
    setWindowMinSize(const Size(windowWidth, windowHeight));
    setWindowMaxSize(const Size(windowWidth, windowHeight));
    getCurrentScreen().then((screen) {
      setWindowFrame(
        Rect.fromCenter(
          center: screen!.frame.center,
          width: windowWidth,
          height: windowHeight,
        ),
      );
    });
  }
}

GoRouter router() {
  final authService = AuthService();

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(authService.authStateChanges),
    redirect: (context, state) {
      // Get the current auth state - force a direct check from Firebase
      final isLoggedIn = FirebaseAuth.instance.currentUser != null;
      final isGoingToLogin = state.uri.toString() == '/login';

      print(
        "Router redirect - User logged in: $isLoggedIn, Going to login: $isGoingToLogin, Path: ${state.uri}",
      );

      // If not logged in and not going to login, redirect to login
      if (!isLoggedIn && !isGoingToLogin) {
        return '/login';
      }

      // If logged in and going to login, redirect to catalog
      if (isLoggedIn && isGoingToLogin) {
        return '/catalog';
      }

      // No redirection needed
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const MyLogin()),
      GoRoute(
        path: '/catalog',
        builder: (context, state) => const MyCatalog(),
        routes: [
          GoRoute(path: 'cart', builder: (context, state) => const MyCart()),
        ],
      ),
    ],
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Using MultiProvider is convenient when providing multiple objects.
    return MultiProvider(
      providers: [
        // Add a StreamProvider for authentication state
        StreamProvider<User?>.value(
          value: FirebaseAuth.instance.authStateChanges(),
          initialData: null,
        ),
        // In this sample app, CatalogModel never changes, so a simple Provider
        // is sufficient.
        Provider(create: (context) => CatalogModel()),
        // CartModel is implemented as a ChangeNotifier, which calls for the use
        // of ChangeNotifierProvider. Moreover, CartModel depends
        // on CatalogModel, so a ProxyProvider is needed.
        ChangeNotifierProxyProvider<CatalogModel, CartModel>(
          create: (context) => CartModel(),
          update: (context, catalog, cart) {
            if (cart == null) throw ArgumentError.notNull('cart');
            cart.catalog = catalog;
            return cart;
          },
        ),
      ],
      child: MaterialApp.router(
        title: 'Provider Demo',
        theme: appTheme,
        routerConfig: router(),
      ),
    );
  }
}
