import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trenord/widgets/location_header.dart';
import 'package:trenord/widgets/journey_card.dart';
import 'package:trenord/widgets/nearby_places_list.dart';
import 'package:trenord/widgets/trenord_app_bar.dart';
import 'package:trenord/controllers/auth_controller.dart';
import 'package:trenord/controllers/journey_controller.dart';
import 'package:trenord/controllers/tts_controller.dart';
import 'package:trenord/controllers/main_screen_controller.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver, RouteAware {
  final authController = Get.find<AuthController>();
  final journeyController = Get.find<JourneyController>();
  final ttsController = Get.find<TtsController>();
  final mainScreenController = Get.find<MainScreenController>();
  final RouteObserver<PageRoute> routeObserver = Get.find<RouteObserver<PageRoute>>();
  

  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Monitor bottom navigation bar switching
    ever(mainScreenController.currentIndex, (index) {
      if (index == 0) { // 0 is the index of the Home page
        _speakWelcomeMessage();
      }
    });

    // Play the welcome audio only on first load
    if (_isFirstLoad) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _speakWelcomeMessage();
        _isFirstLoad = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }


  void _speakWelcomeMessage() {
    if (!ttsController.isTtsEnabled.value) return;

    if (authController.user.value == null) {
      ttsController.speak('Welcome to Home page. Please log in to view your trips.');
      return;
    }

    final latestJourney = journeyController.latestJourney.value;
    if (latestJourney != null) {
      final departureTime = DateFormat('HH:mm').format(latestJourney.departureTime);
      ttsController.speak(
        'Welcome to Home page. You have an upcoming trip to ${latestJourney.arrivalStation} at $departureTime.'
      );
    } else {
      ttsController.speak('Welcome to Home page. You have no upcoming trips.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F2F7),
      appBar: const TrenordAppBar(),
      body: const SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              LocationHeader(),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent trips',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    JourneyCard(),
                    SizedBox(height: 24),
                    Text(
                      'Train trips',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    NearbyPlacesList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 