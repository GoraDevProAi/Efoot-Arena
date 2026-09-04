import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Background FCM handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Init notifications (permissions + token)
  await NotificationService().initialize();

  runApp(
    const ProviderScope(
      child: EFootArenaApp(),
    ),
  );
}

class EFootArenaApp extends ConsumerStatefulWidget {
  const EFootArenaApp({super.key});

  @override
  ConsumerState<EFootArenaApp> createState() => _EFootArenaAppState();
}

class _EFootArenaAppState extends ConsumerState<EFootArenaApp> {
  @override
  void initState() {
    super.initState();
    // Deep link from notification tap
    NotificationService.onNotificationTap = ({type, route, data}) {
      final router = ref.read(appRouterProvider);
      if (route != null && route.isNotEmpty) {
        router.go(route);
        return;
      }
      switch (type) {
        case 'challenge':
          router.go('/challenges');
          break;
        case 'team':
          router.go('/teams');
          break;
        default:
          router.go('/');
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'eFoot Arena',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
