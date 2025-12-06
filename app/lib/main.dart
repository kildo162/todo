import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/login/login_screen.dart';
import 'package:app/home/base_screen.dart';
import 'package:app/shared/local_notification_service.dart';
import 'package:app/shared/app_theme.dart';
import 'package:app/services/discovery_service.dart';
import 'package:app/services/api_config.dart';
import 'package:app/services/api_client.dart';
import 'package:app/shared/session.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await LocalNotificationService.instance.init();
  }
  // Try discovering local backend first. If not found, fallback to BASE_URL.
  final base = await DiscoveryService.discoverOrFallback();
  // update ApiConfig to reflect chosen base (discovery sets it too).
  ApiConfig.setBaseUrl(base);
  print('Selected API base: $base');
  // Register shared services
  final session = Get.put(SessionController(), permanent: true);
  final apiClient = Get.put(ApiClient(), permanent: true);
  // bind session token to apiClient
  session.authToken.listen((t) {
    apiClient.setAuthToken(t);
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App',
      theme: AppTheme.light,
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/home', page: () => BaseScreen()),
      ],
    );
  }
}
