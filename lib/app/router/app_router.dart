
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/profile_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';

// Replace with the actual path of your HomeScreen.
import '../../features/home/presentation/screens/home_screen.dart';

import 'auth_refresh_notifier.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  // Listen for Supabase authentication changes.
  final authRefreshNotifier = AuthRefreshNotifier();

  // Dispose the listener when Riverpod disposes the router provider.
  ref.onDispose(() {
    authRefreshNotifier.dispose();
  });

  return GoRouter(
    initialLocation: '/home',

    // Refresh GoRouter whenever authentication changes.
    refreshListenable: authRefreshNotifier,

    // Authentication-based navigation.
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isLoggedIn = session != null;

      final location = state.matchedLocation;

      // Routes accessible without login.
      final isPublicRoute = location == '/login' ||
          location == '/register' ||
          location == '/forgot-password';

      // Logged-out users cannot access protected routes.
      if (!isLoggedIn && !isPublicRoute) {
        return '/login';
      }

      // Logged-in users should not visit login or register.
      if (isLoggedIn &&
          (location == '/login' || location == '/register')) {
        return '/home';
      }

      return null;
    },

    routes: [
      // Login
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Registration
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Forgot Password
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Home
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),

      // User Profile
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
});
