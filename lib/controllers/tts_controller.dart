import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TtsController extends GetxController {
  final FlutterTts flutterTts = FlutterTts();
  var isSpeaking = false.obs;
  var isTtsEnabled = false.obs;

  static const String _ttsEnabledKey = 'tts_enabled';

  @override
  void onInit() {
    super.onInit();
    _loadTtsState();
    _initTts();
  }

  Future<void> _loadTtsState() async {
    final prefs = await SharedPreferences.getInstance();
    isTtsEnabled.value = prefs.getBool(_ttsEnabledKey) ?? false;
  }

  Future<void> _saveTtsState(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_ttsEnabledKey, enabled);
  }

  // Initialize TTS settings
  Future<void> _initTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setVoice({"name": "en-us-x-tpf-local", "locale": "en-US"});
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(0.8);
    await flutterTts.setPitch(1.0);

    await flutterTts.setIosAudioCategory(
      IosTextToSpeechAudioCategory.ambient,
      [
        IosTextToSpeechAudioCategoryOptions.allowBluetooth,
        IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
        IosTextToSpeechAudioCategoryOptions.mixWithOthers,
      ],
    );

    flutterTts.setStartHandler(() {
      isSpeaking.value = true;
    });

    flutterTts.setCompletionHandler(() {
      isSpeaking.value = false;
    });

    flutterTts.setErrorHandler((msg) {
      isSpeaking.value = false;
    });
  }

  void setTtsEnabled(bool enabled) {
    isTtsEnabled.value = enabled;
    _saveTtsState(enabled);
  }

  Future<void> speak(String text) async {
    if (!isTtsEnabled.value || text.isEmpty) return;
    // If speaking, stop the current voice immediately
    if (isSpeaking.value) {
      await flutterTts.stop();
      // Add a small delay to ensure the previous speak stops completely
      await Future.delayed(const Duration(milliseconds: 100));
    }

    await flutterTts.speak(text);
  }

  Future<void> stop() async {
    if (isSpeaking.value) {
      await flutterTts.stop();
      isSpeaking.value = false;
    }
  }

  @override
  void onClose() {
    flutterTts.stop();
    super.onClose();
  }
}
