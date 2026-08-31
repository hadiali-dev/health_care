// core/router/app_router.dart

import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthcare_app/core/models/user_model.dart';
import 'package:healthcare_app/features/auth/forgot_password/forgot_password.dart';
import 'package:healthcare_app/features/auth/login/login_screen.dart';
import 'package:healthcare_app/features/auth/register/register_screen.dart';
import 'package:healthcare_app/features/auth/welcom/welcom_screen.dart';
import 'package:healthcare_app/features/patient/patient_main_screen.dart';
import 'package:healthcare_app/features/staff/staff_main_screen.dart';
import 'go_router_refresh_stream.dart';
import '../services/auth_service.dart';
import 'package:healthcare_app/features/patient/nearby_patient_map_screen.dart';
final AuthService _authService = AuthService();

final GoRouter appRouter = GoRouter(
  initialLocation: '/welcome',
  refreshListenable: GoRouterRefreshStream(
    FirebaseAuth.instance.authStateChanges(),
  ),
  redirect: (context, state) async {
  final loggedIn = FirebaseAuth.instance.currentUser != null;
  final currentPath = state.matchedLocation;

  final publicPaths = [
    '/welcome',
    '/register',
    '/login',
    '/forgot-password',
  ];
  final isPublicPath = publicPaths.contains(currentPath);

  // Not logged in, trying to reach a protected route -> force to login.
  if (!loggedIn && !isPublicPath) {
    return '/login';
  }

  // Logged in, but sitting on a public/auth-only screen -> send them
  // to the correct role shell instead.
  if (loggedIn && isPublicPath) {
    UserModel? userModel;
    try {
      userModel = await _authService.getCurrentUserModel();
    } catch (_) {
      userModel = null;
    }

    if (userModel == null) {
      return '/login';
    }

    return userModel.role == 'medical_staff' ? '/staff' : '/patient';
  }

  return null;
},
  routes: [
    GoRoute(
      path: '/welcome',
      builder: (context, state) =>
          const WelcomeScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) =>
          const RegisterScreen()),
    GoRoute(
      path: '/login',
      builder: (context, state) =>
          const LoginScreen()),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) =>
          const ForgotPasswordScreen()),

// ...keep all existing imports...

// ...inside routes: [ ... ], add:
    GoRoute(
      path: '/map',
      builder: (context, state) => const NearbyPatientsMapScreen(),
    ),
    GoRoute(
      path: '/staff',
      builder: (context, state) =>
          const StaffMainScreen()
    ),
    GoRoute(
      path: '/patient',
      builder: (context, state) =>
          const PatientMainScreen()
    ),
  ],
);