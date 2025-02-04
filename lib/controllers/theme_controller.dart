import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:trenord/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  static const String _primaryColorKey = 'primary_color';
  static const String _brightnessKey = 'brightness';

  final RxDouble _brightness = 1.0.obs;
  final Rx<Color> _primaryColor = AppTheme.primaryColor.obs;
  final RxDouble _contrast = 1.0.obs;

  double get brightness => _brightness.value;
  Color get primaryColor => _primaryColor.value;
  double get contrast => _contrast.value;

  @override
  void onInit() {
    super.onInit();
    _loadThemeSettings();
  }

  Future<void> _loadThemeSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final primaryColorValue = prefs.getInt(_primaryColorKey);
    if (primaryColorValue != null) {
      _primaryColor.value = Color(primaryColorValue);
    }

    final brightnessValue = prefs.getDouble(_brightnessKey);
    if (brightnessValue != null) {
      _brightness.value = brightnessValue;
    }

    _updateTheme();
  }

  // Save setting
  Future<void> _saveThemeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_primaryColorKey, _primaryColor.value.value);
    await prefs.setDouble(_brightnessKey, _brightness.value);
  }

  void updateBrightness(double value) {
    _brightness.value = value;
    _updateTheme();
    _saveThemeSettings();
  }

  void updatePrimaryColor(Color color) {
    _primaryColor.value = color;
    _updateTheme();
    _saveThemeSettings();
  }

  void _updateTheme() {
    final adjustedColor = HSLColor.fromColor(_primaryColor.value)
        .withLightness(HSLColor.fromColor(_primaryColor.value).lightness * _brightness.value)
        .toColor();

    Get.changeTheme(
      AppTheme.createTheme(
        primaryColor: adjustedColor,
        brightness: _brightness.value,
        contrast: _contrast.value,
      ),
    );
  }

  void resetToDefault() {
    _brightness.value = 1.0;
    _primaryColor.value = AppTheme.primaryColor;
    _contrast.value = 1.0;
    _updateTheme();
    _saveThemeSettings();
  }
} 