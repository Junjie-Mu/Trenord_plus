import 'package:flutter/material.dart';
import 'package:trenord/screens/home/home_screen.dart';
import 'package:trenord/screens/travel/travel_screen.dart';
import 'package:trenord/screens/profile/profile_screen.dart';
import 'package:get/get.dart';
import 'package:trenord/controllers/main_screen_controller.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MainScreenController());
    
    return Scaffold(
      body: Obx(() => IndexedStack(
        index: controller.currentIndex.value,
        children: [
          const HomeScreen(),
          const TravelScreen(),
          ProfileScreen(),
        ],
      )),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        currentIndex: controller.currentIndex.value,
        onTap: controller.changeTab,
        selectedItemColor: const Color(0xFF1B8E3D),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.train_outlined),
            activeIcon: Icon(Icons.train),
            label: 'Ticket',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      )),
    );
  }
} 