import 'package:flutter/material.dart';
import 'package:trenord/widgets/trenord_app_bar.dart';
import 'package:get/get.dart';
import 'package:trenord/controllers/auth_controller.dart';
import 'package:trenord/controllers/journey_controller.dart';
import 'package:trenord/controllers/main_screen_controller.dart';
import 'package:trenord/utils/ui_utils.dart';
import 'package:intl/intl.dart';
import 'package:trenord/screens/profile/profile_screen.dart';
import 'package:trenord/controllers/tts_controller.dart';
import 'package:flutter/rendering.dart';
import 'package:rxdart/rxdart.dart';

class AddTripDialog extends StatefulWidget {
  const AddTripDialog({super.key});

  @override
  State<AddTripDialog> createState() => _AddTripDialogState();
}

class _AddTripDialogState extends State<AddTripDialog> {
  final TextEditingController trainNumberController = TextEditingController();
  final TextEditingController departureStationController = TextEditingController();
  final TextEditingController arrivalStationController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  TimeOfDay departureTime = const TimeOfDay(hour: 9, minute: 30);
  TimeOfDay arrivalTime = const TimeOfDay(hour: 10, minute: 15);

  // add ticket dialog
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: 400,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Add ticket.',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      color: Colors.grey[600],
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: trainNumberController,
                  decoration: InputDecoration(
                    labelText: 'Train No.',
                    labelStyle: TextStyle(color: Colors.grey[600]),
                    prefixIcon: Icon(Icons.train_outlined, color: Colors.grey[600]),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF1B8E3D)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: departureStationController,
                        decoration: InputDecoration(
                          labelText: 'Dep.',
                          labelStyle: TextStyle(color: Colors.grey[600]),
                          prefixIcon: Icon(Icons.location_on_outlined, color: Colors.grey[600]),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF1B8E3D)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(Icons.arrow_forward, color: Colors.grey[400], size: 20),
                    ),
                    Expanded(
                      child: TextField(
                        controller: arrivalStationController,
                        decoration: InputDecoration(
                          labelText: 'Arrival',
                          labelStyle: TextStyle(color: Colors.grey[600]),
                          prefixIcon: Icon(Icons.location_on_outlined, color: Colors.grey[600]),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF1B8E3D)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030, 12, 31),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: Color(0xFF1B8E3D),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, color: Colors.grey[600]),
                        const SizedBox(width: 12),
                        Text(
                          DateFormat('dd/MM/yyyy').format(selectedDate),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTimeSelector(
                        label: 'Departure time',
                        time: departureTime,
                        onTap: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: departureTime,
                            builder: (context, child) {
                              return Theme(
                                data: _createTimePickerTheme(context),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            setState(() {
                              departureTime = picked;
                            });
                          }
                        },
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(Icons.arrow_forward, color: Colors.grey[400], size: 20),
                    ),
                    Expanded(
                      child: _buildTimeSelector(
                        label: 'Arrival time',
                        time: arrivalTime,
                        onTap: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: arrivalTime,
                            builder: (context, child) {
                              return Theme(
                                data: _createTimePickerTheme(context),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            setState(() {
                              arrivalTime = picked;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final journeyController = Get.find<JourneyController>();
                      
                      if (trainNumberController.text.isEmpty ||
                          departureStationController.text.isEmpty ||
                          arrivalStationController.text.isEmpty) {
                        UIUtils.showError('Error', 'Incomplete ticket info');
                        return;
                      }

                      final departureDateTime = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        departureTime.hour,
                        departureTime.minute,
                      );

                      final arrivalDateTime = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        arrivalTime.hour,
                        arrivalTime.minute,
                      );

                      await journeyController.addJourney(
                        trainNumber: trainNumberController.text,
                        departureStation: departureStationController.text,
                        arrivalStation: arrivalStationController.text,
                        departureTime: departureDateTime,
                        arrivalTime: arrivalDateTime,
                        date: selectedDate,
                      );

                      Navigator.pop(context);
                      UIUtils.showSuccess('Success', 'Ticket added successfully');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B8E3D),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Add ticket',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSelector({
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Text(
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  ThemeData _createTimePickerTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF1B8E3D),
        onPrimary: Colors.white,
        surface: Colors.white,
        onSurface: Color(0xFF1F2937),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF1B8E3D),
        ),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: Colors.white,
        hourMinuteShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey[200]!),
        ),
        dayPeriodShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey[200]!),
        ),
        dayPeriodColor: MaterialStateColor.resolveWith((states) => 
          states.contains(MaterialState.selected) ? const Color(0xFF1B8E3D).withOpacity(0.12) : Colors.transparent
        ),
        dayPeriodTextColor: MaterialStateColor.resolveWith((states) =>
          states.contains(MaterialState.selected) ? const Color(0xFF1B8E3D) : Colors.grey[700]!
        ),
        hourMinuteColor: MaterialStateColor.resolveWith((states) =>
          states.contains(MaterialState.selected) ? const Color(0xFF1B8E3D).withOpacity(0.12) : Colors.grey[50]!
        ),
        hourMinuteTextColor: MaterialStateColor.resolveWith((states) =>
          states.contains(MaterialState.selected) ? const Color(0xFF1B8E3D) : Colors.grey[700]!
        ),
        dialHandColor: const Color(0xFF1B8E3D),
        dialBackgroundColor: Colors.grey[50],
        dialTextColor: MaterialStateColor.resolveWith((states) =>
          states.contains(MaterialState.selected) ? Colors.white : Colors.grey[700]!
        ),
        entryModeIconColor: Colors.grey[600],
      ),
    );
  }

  @override
  void dispose() {
    trainNumberController.dispose();
    departureStationController.dispose();
    arrivalStationController.dispose();
    super.dispose();
  }
}

class TravelScreen extends StatefulWidget {
  const TravelScreen({super.key});

  @override
  State<TravelScreen> createState() => _TravelScreenState();
}

class _TravelScreenState extends State<TravelScreen> with RouteAware {
  final authController = Get.find<AuthController>();
  final journeyController = Get.find<JourneyController>();
  final ttsController = Get.find<TtsController>();
  final mainScreenController = Get.find<MainScreenController>();
  final RouteObserver<PageRoute> routeObserver = Get.find<RouteObserver<PageRoute>>();

  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    
    // Monitor bottom navigation bar switching
    ever(mainScreenController.currentIndex, (index) {
      if (index == 1) { // 1 is the index of the Travel page
        _speakWelcomeMessage();
      }
    });

    // Play welcome message on first load
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
    super.dispose();
  }

  void _speakWelcomeMessage() {
    if (!ttsController.isTtsEnabled.value) return;

    if (authController.user.value == null) {
      ttsController.speak('Welcome to Travel page. Please log in to view and manage your tickets.');
      return;
    }

    final futureJourneys = journeyController.futureJourneys;
    final ticketCount = futureJourneys.length;
    
    if (ticketCount > 0) {
      ttsController.speak(
        'Welcome to Travel page. You have $ticketCount ${ticketCount == 1 ? 'unused ticket' : 'unused tickets'}.'
      );
    } else {
      ttsController.speak('Welcome to Travel page. You have no unused tickets.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F2F7),
      appBar: const TrenordAppBar(),
      body: Obx(() {
        final user = authController.user.value;

        if (user == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.train_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Log in to view ticket',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Get.find<MainScreenController>().changeTab(2),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Log In'),
                ),
              ],
            ),
          );
        }

        return _buildTripsList(journeyController);
      }),
      floatingActionButton: Obx(() {
        final user = authController.user.value;
        if (user == null) return const SizedBox();

        return FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const AddTripDialog(),
            );
          },
          backgroundColor: const Color(0xFF1B8E3D),
          child: const Icon(Icons.add),
        );
      }),
    );
  }

  Widget _buildTripsList(JourneyController journeyController) {
    return Obx(() {
      final journeys = journeyController.futureJourneys;
      
      if (journeys.isEmpty) {
        return const Center(
          child: Text(
            'No Trip Present',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: journeys.length,
        itemBuilder: (context, index) {
          final journey = journeys[index];
          return Dismissible(
            key: Key(journey.id),
            background: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 16),
              child: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              journeyController.deleteJourney(journey.id);
            },
            child: Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () {
                  if (ttsController.isTtsEnabled.value) {
                    final departureTime = DateFormat('HH:mm').format(journey.departureTime);
                    final arrivalTime = DateFormat('HH:mm').format(journey.arrivalTime);
                    final date = DateFormat('MMMM dd').format(journey.date);
                    
                    ttsController.speak(
                      'Train ${journey.trainNumber} on $date. '
                      'Departing from ${journey.departureStation} at $departureTime, '
                      'arriving at ${journey.arrivalStation} at $arrivalTime.'
                    );
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Image.asset(
                                'assets/images/RE.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('dd/MM/yyyy').format(journey.date),
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                journey.trainNumber,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat('HH:mm').format(journey.departureTime),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  journey.departureStation,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward,
                            color: Colors.grey,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  DateFormat('HH:mm').format(journey.arrivalTime),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  journey.arrivalStation,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }
}