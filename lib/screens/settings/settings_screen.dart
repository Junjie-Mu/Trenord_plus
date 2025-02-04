import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trenord/controllers/theme_controller.dart';
import 'package:trenord/widgets/trenord_app_bar.dart';
import 'package:trenord/theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F2F7),
      appBar: const TrenordAppBar(
        showBackButton: true,
        title: 'SettingsScreen',
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Text(
                'Customization',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Theme color',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => themeController.resetToDefault(),
                          icon: const Icon(Icons.refresh, size: 20),
                          label: const Text('Restore default'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey[600],
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Row(
                      children: [
                        _buildColorOption(themeController, AppTheme.primaryColor),
                        _buildColorOption(themeController, Colors.blue),
                        _buildColorOption(themeController, Colors.indigo),
                        _buildColorOption(themeController, Colors.purple),
                        _buildColorOption(themeController, Colors.pink),
                        _buildColorOption(themeController, Colors.red),
                        _buildColorOption(themeController, Colors.orange),
                        _buildColorOption(themeController, Colors.amber),
                        _buildColorOption(themeController, Colors.teal),
                        _buildColorOption(themeController, Colors.cyan),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Brightness',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                    child: Row(
                      children: [
                        const SizedBox(width: 8),
                        Icon(Icons.brightness_low, color: Colors.grey[400]),
                        Expanded(
                          child: Obx(() => Slider(
                            value: themeController.brightness,
                            min: 0.5,
                            max: 1.5,
                            onChanged: themeController.updateBrightness,
                          )),
                        ),
                        Icon(Icons.brightness_high, color: Colors.grey[400]),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorOption(ThemeController controller, Color color) {
    return Obx(() {
      final isSelected = controller.primaryColor.value == color;
      return Padding(
        padding: const EdgeInsets.only(right: 16),
        child: GestureDetector(
          onTap: () => controller.updatePrimaryColor(color),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 6,
                  spreadRadius: isSelected ? 2 : 0,
                ),
              ],
            ),
            child: isSelected
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 20,
                  )
                : null,
          ),
        ),
      );
    });
  }
} 