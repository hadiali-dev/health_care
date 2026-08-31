import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:healthcare_app/core/router/app_router.dart';
import 'package:healthcare_app/core/theme/app_theme.dart';
import 'package:healthcare_app/core/services/notification_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

await NotificationService.instance.initialize(
  onNotificationTap: () => appRouter.push('/map'), // was appRouter.go('/map')
);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      title: 'CareTrack',
      theme: AppTheme.lightTheme,
    );
  }
}