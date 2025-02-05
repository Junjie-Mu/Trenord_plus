import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trenord/screens/main_screen.dart';
import 'package:trenord/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:trenord/controllers/location_controller.dart';
import 'package:trenord/controllers/home_controller.dart';
import 'package:trenord/controllers/main_screen_controller.dart';
import 'package:trenord/controllers/journey_controller.dart';
import 'package:trenord/controllers/auth_controller.dart';
import 'package:trenord/controllers/theme_controller.dart';
import 'package:trenord/controllers/tts_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  Get.put(RouteObserver<PageRoute>());
  
  Get.put(AuthController(), permanent: true);
  Get.put(LocationController());
  Get.put(HomeController());
  Get.put(MainScreenController());
  Get.put(JourneyController());
  Get.put(ThemeController());
  Get.put(TtsController());

  runApp(const TrenordPlusApp());
}

class TrenordPlusApp extends StatelessWidget {
  const TrenordPlusApp({super.key});
  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    return Obx(() => GetMaterialApp(
      title: 'Trenord+',
      theme: AppTheme.createTheme(
        primaryColor: themeController.primaryColor,
        brightness: themeController.brightness,
        contrast: themeController.contrast,
      ),
      navigatorObservers: [Get.find<RouteObserver<PageRoute>>()],
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    ));
  }
}
