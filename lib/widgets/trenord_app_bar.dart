import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trenord/screens/notification/notification_screen.dart';
import 'package:trenord/controllers/auth_controller.dart';
import 'package:trenord/controllers/journey_controller.dart';

class TrenordAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;
  final bool showBackButton;
  final String? title;

  const TrenordAppBar({
    super.key,
    this.actions,
    this.showBackButton = false,
    this.title,
  });

  bool _hasNotification() {
    final authController = Get.find<AuthController>();
    final journeyController = Get.find<JourneyController>();
    final user = authController.user.value;
    
    if (user == null) return false;
    
    final latestJourney = journeyController.latestJourney.value;
    if (latestJourney == null) return false;
    
    final now = DateTime.now();
    return latestJourney.departureTime.difference(now).inHours < 24 && 
           latestJourney.departureTime.isAfter(now);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppBar(
      backgroundColor: theme.primaryColor,
      leading: showBackButton ? const BackButton(color: Colors.white) : null,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/logo-mob.png',
            height: 15,
          ),
          const SizedBox(width: 6),
          const Text(
            '+',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              height: 1,
              fontWeight: FontWeight.w500,
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: actions ?? [
        Obx(() => Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Colors.white),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationScreen(),
                  ),
                  (route) => route.isFirst,
                );
              },
            ),
            if (_hasNotification())
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        )),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
} 