import 'package:get/get.dart';
import 'package:trenord/models/journey.dart';
import 'package:trenord/services/journey_service.dart';
import 'package:trenord/controllers/auth_controller.dart';

class JourneyController extends GetxController {
  final JourneyService _journeyService = JourneyService();
  final AuthController _authController = Get.find<AuthController>();

  // All tickets
  final RxList<Journey> userJourneys = <Journey>[].obs;
  // Future tickets
  final RxList<Journey> futureJourneys = <Journey>[].obs;
  final Rxn<Journey> latestJourney = Rxn<Journey>();

  @override
  void onInit() {
    super.onInit();
    _setupJourneyListeners();
  }

  void _setupJourneyListeners() {
    ever(_authController.user, (user) {
      if (user != null) {
        // Monitor all ticket
        _journeyService.getAllUserJourneys(user.uid).listen((journeys) {
          userJourneys.value = journeys;
        });

        // Monitor future ticket
        _journeyService.getFutureJourneys(user.uid).listen((journeys) {
          futureJourneys.value = journeys;
        });

        // Monitor newest ticket
        _journeyService.getLatestJourney(user.uid).listen((journey) {
          latestJourney.value = journey;
        });
      } else {
        userJourneys.clear();
        futureJourneys.clear();
        latestJourney.value = null;
      }
    });
  }

  Future<void> addJourney({
    required String trainNumber,
    required String departureStation,
    required String arrivalStation,
    required DateTime departureTime,
    required DateTime arrivalTime,
    required DateTime date,
  }) async {
    if (_authController.user.value == null) return;

    final journey = Journey(
      id: '',
      userId: _authController.user.value!.uid,
      trainNumber: trainNumber,
      departureStation: departureStation,
      arrivalStation: arrivalStation,
      departureTime: departureTime,
      arrivalTime: arrivalTime,
      date: date,
    );

    await _journeyService.addJourney(journey);
  }

  Future<void> deleteJourney(String journeyId) async {
    await _journeyService.deleteJourney(journeyId);
  }
} 