import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trenord/controllers/auth_controller.dart';
import 'package:trenord/widgets/trenord_app_bar.dart';
import 'package:trenord/utils/ui_utils.dart';
import 'package:trenord/screens/tickets/my_tickets_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:trenord/screens/settings/settings_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:trenord/controllers/tts_controller.dart';
import 'package:trenord/controllers/main_screen_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with RouteAware {
  late final AuthController authController;
  late final TtsController ttsController;
  late final MainScreenController mainScreenController;
  final RouteObserver<PageRoute> routeObserver = Get.find<RouteObserver<PageRoute>>();
  late final RxBool hasEmergencyContact;
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    authController = Get.put(AuthController());
    ttsController = Get.put(TtsController());
    mainScreenController = Get.find<MainScreenController>();
    hasEmergencyContact = false.obs;

    // Monitor bottom navigation bar switching
    ever(mainScreenController.currentIndex, (index) {
      if (index == 2) { // 2 is the index of the Profile page
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
      ttsController.speak('Welcome to Profile page. Please log in.');
      return;
    }

    ttsController.speak(
      'Welcome to Profile page. You can click My tickets to view all your tickets.'
    );
  }

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _launchTrenordWebsite() async {
    final Uri url = Uri.parse('https://www.trenord.it/');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _shareLocation() async {
    try {
      // Loading
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1B8E3D)),
          ),
        ),
        // Disable background close on click
        barrierDismissible: false,
      );

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        Get.back();
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          UIUtils.showError(
              'Error', 'Please grant the app location permission');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.back();
        UIUtils.showError('Error',
            'Please grant location permission for the app in settings');
        return;
      }

      // Get current location
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Close loading dialog
      Get.back();

      // Google map location link
      final String googleMapsUrl =
          'https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}';

      // Share Location
      await Share.share(
        '''I'm here:\n $googleMapsUrl''',
        subject: 'Share Location',
      );
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      UIUtils.showError('Error', 'Failed to get location');
    }
  }

  Future<void> _handleSOS() async {
    try {
      final user = authController.user.value;
      if (user == null) {
        UIUtils.showInfo('Message', 'Please log in');
        return;
      }

      Get.dialog(
        const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1B8E3D)),
          ),
        ),
        barrierDismissible: false,
      );

      // Get emergency contact information.
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      // Get curent location
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final String googleMapsUrl =
          'https://maps.google.com/?q=${position.latitude},${position.longitude}';

      Get.back();
      // If an emergency contact is set, send an SMS
      if (doc.exists && doc.data()?['emergencyContact'] != null) {
        final emergencyContact = doc.data()!['emergencyContact'];
        final phone = emergencyContact['phone'];
        final name = emergencyContact['name'];

        final message = Uri.encodeComponent(
            'SOS！I\'m ${user.email}, I\'m in an emergency situation and need help!'
            '\nMy current location：$googleMapsUrl');

        final Uri smsUri = Uri.parse('sms:$phone?body=$message');

        if (!await launchUrl(smsUri)) {
          UIUtils.showError('Error', 'Unable to open SMS');
          _callEmergency();
        }
      } else {
        //No emergency contact, call 112 directly.
        _callEmergency();
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      _callEmergency();
    }
  }

  Future<void> _callEmergency() async {
    final Uri telUri = Uri.parse('tel:112');
    if (!await launchUrl(telUri)) {
      UIUtils.showError('Error', 'Unable to open Dialer');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F2F7),
      appBar: const TrenordAppBar(),
      body: SingleChildScrollView(
        child: Obx(() {
          final user = authController.user.value;

          return Column(
            children: [
              // User Information/Login
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 0,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: user != null
                      // If logged in display user information
                      ? _buildUserInfo(user)
                      // If not logged in show login
                      : _buildLoginButtons(context),
                ),
              ),
              // Security Center
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 0,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Security Center',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildSecurityItems(user),
                  ],
                ),
              ),
              // Functions list
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 0,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Icons.confirmation_number_outlined,
                      title: 'My tickets',
                      subtitle: 'View all added tickets',
                    ),
                    _buildMenuItem(
                      icon: Icons.settings_outlined,
                      title: 'Appearance',
                      subtitle: 'Adjust interface color',
                    ),
                    _buildMenuItem(
                      icon: Icons.info_outlined,
                      title: 'About',
                      subtitle: 'About Trenord',
                    ),
                    _buildTtsMenuItem(),
                    const Divider(height: 1),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    bool showBorder = true,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(
            icon,
            color: const Color(0xFF1B8E3D),
            size: 28,
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: Colors.grey[400],
          ),
          onTap: () {
            if (title == 'My tickets') {
              Get.to(() => const MyTicketsScreen());
            } else if (title == 'About') {
              _launchTrenordWebsite();
            } else if (title == 'Appearance') {
              Get.to(() => const SettingsScreen());
            }
          },
        ),
        if (showBorder)
          Divider(
            height: 1,
            indent: 72,
            color: Colors.grey[200],
          ),
      ],
    );
  }

  Widget _buildTtsMenuItem() {
    return Column(
      children: [
        ListTile(
          leading: Icon(
            Icons.record_voice_over,
            color: const Color(0xFF1B8E3D),
            size: 28,
          ),
          title: const Text(
            'Assistant',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            'Text to Speech',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          trailing: Obx(() => Switch(
            value: ttsController.isTtsEnabled.value,
            onChanged: (value) {
              ttsController.setTtsEnabled(value);
              if (value) {
                ttsController.speak('Text to speech is now enabled');
              }
            },
            activeColor: const Color(0xFF1B8E3D),
          )),
        ),
        Divider(
          height: 1,
          indent: 72,
          color: Colors.grey[200],
        ),
      ],
    );
  }

  void _showEmergencyContactDialog(BuildContext context, String? userId) {
    if (userId == null) return;

    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final hasExistingContact = false.obs;

    // Get emergency contact information if existing
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get()
        .then((doc) {
      if (doc.exists) {
        final emergencyContact = doc.data()?['emergencyContact'];
        if (emergencyContact != null) {
          nameController.text = emergencyContact['name'] ?? '';
          phoneController.text = emergencyContact['phone'] ?? '';
          hasExistingContact.value = true;
        }
      }
    });

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.contact_phone,
                      color: Colors.blue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Set emergency contact',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
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
              const SizedBox(height: 24),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Contact name',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone number',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Obx(() => hasExistingContact.value
                      ? TextButton.icon(
                          onPressed: () async {
                            try {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(userId)
                                  .update({
                                'emergencyContact': FieldValue.delete(),
                              });

                              nameController.clear();
                              phoneController.clear();
                              hasExistingContact.value = false;

                              UIUtils.showSuccess(
                                  'Success', 'Emergency contact deleted');
                              _checkEmergencyContact(userId); // update
                            } catch (e) {
                              print('Error deleting emergency contact: $e');
                              UIUtils.showError('Error', 'Delete error');
                            }
                          },
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red),
                          label: const Text('Delete',
                              style: TextStyle(color: Colors.red)),
                        )
                      : const SizedBox()),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      if (nameController.text.isEmpty ||
                          phoneController.text.isEmpty) {
                        UIUtils.showError('Error', 'Please fill all');
                        return;
                      }

                      try {
                        final userDoc = FirebaseFirestore.instance
                            .collection('users')
                            .doc(userId);

                        final docSnapshot = await userDoc.get();
                        if (!docSnapshot.exists) {
                          await userDoc.set({
                            'uid': userId,
                            'emergencyContact': {
                              'name': nameController.text,
                              'phone': phoneController.text,
                            }
                          });
                        } else {
                          await userDoc.update({
                            'emergencyContact': {
                              'name': nameController.text,
                              'phone': phoneController.text,
                            }
                          });
                        }

                        Navigator.pop(context);
                        UIUtils.showSuccess('Success', 'Settings saved');
                        _checkEmergencyContact(userId);
                      } catch (e) {
                        UIUtils.showError('Error', 'Save failed');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityItems(User? user) {
    // Check emergency contact status when the user's status changes
    _checkEmergencyContact(user?.uid);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: _buildSecurityItem(
              icon: Icons.location_on,
              title: 'Location',
              subtitle: 'Tap to share loction',
              color: const Color(0xFF1B8E3D),
              isLoggedIn: user != null,
              onTap: _shareLocation,
            ),
          ),
          Expanded(
            child: _buildSecurityItem(
              icon: Icons.emergency,
              title: 'SOS',
              subtitle: 'Tap for SOS',
              color: Colors.red,
              isLoggedIn: true,
              onTap: _handleSOS,
            ),
          ),
          Expanded(
            child: Obx(() => _buildSecurityItem(
                  icon: Icons.contact_phone,
                  title: 'Contact',
                  subtitle: hasEmergencyContact.value ? 'Set' : 'Not set',
                  subtitleColor: hasEmergencyContact.value
                      ? const Color(0xFF1B8E3D)
                      : null,
                  color: Colors.blue,
                  isLoggedIn: user != null,
                )),
          ),
        ],
      ),
    );
  }

  // Check if user has set emergency contact
  void _checkEmergencyContact(String? userId) {
    if (userId == null) {
      hasEmergencyContact.value = false;
      return;
    }

    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get()
        .then((doc) {
      if (doc.exists) {
        final emergencyContact = doc.data()?['emergencyContact'];
        hasEmergencyContact.value = emergencyContact != null &&
            emergencyContact['name']?.isNotEmpty == true &&
            emergencyContact['phone']?.isNotEmpty == true;
      } else {
        hasEmergencyContact.value = false;
      }
    });
  }

  Widget _buildSecurityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isLoggedIn,
    Color? subtitleColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: () {
        if (!isLoggedIn) {
          UIUtils.showInfo('Message', 'Please log in');
          return;
        }

        if (title == 'Contact') {
          _showEmergencyContactDialog(
              Get.context!, authController.user.value?.uid);
        } else {
          onTap?.call();
        }
      },
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: subtitleColor ?? Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showLoginDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        backgroundColor: Colors.white,
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    color: Colors.grey[600],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Please enter email address',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'Please enter password',
                  prefixIcon: Icon(Icons.lock_outlined),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    final email = emailController.text.trim();
                    final password = passwordController.text.trim();

                    if (email.isEmpty || password.isEmpty) {
                      UIUtils.showError('Error', 'Please fill all');
                      return;
                    }

                    authController.signIn(email, password);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B8E3D),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRegisterDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        backgroundColor: Colors.white,
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Register',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    color: Colors.grey[600],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Please enter email address',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'Please enter password',
                  prefixIcon: Icon(Icons.lock_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm password',
                  hintText: 'Please re-enter password',
                  prefixIcon: Icon(Icons.lock_outlined),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    final email = emailController.text.trim();
                    final password = passwordController.text.trim();
                    final confirmPassword =
                        confirmPasswordController.text.trim();

                    // Verify integrity
                    if (email.isEmpty ||
                        password.isEmpty ||
                        confirmPassword.isEmpty) {
                      UIUtils.showError('Error', 'Please fill all');
                      return;
                    }

                    // Verify password length
                    if (password.length < 6) {
                      UIUtils.showError('Error', 'Password must be at least 6 characters');
                      return;
                    }

                    // Verify password match
                    if (password != confirmPassword) {
                      UIUtils.showError('Error', 'Passwords entered do not match');
                      return;
                    }

                    // Verify email format
                    if (!email.contains('@')) {
                      UIUtils.showError('Error', 'Invalid Email format');
                      return;
                    }

                    authController.signUp(email, password);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B8E3D),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Register'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo(User user) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: const Color(0xFF1B8E3D).withOpacity(0.1),
          child: Text(
            user.email?[0].toUpperCase() ?? 'U',
            style: const TextStyle(
              fontSize: 32,
              color: Color(0xFF1B8E3D),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          user.email ?? '',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => authController.signOut(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B8E3D),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Log out'),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Log in or Sign up',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'To visualize your information enter your personal area',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 24),
        // Log in button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _showLoginDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B8E3D),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'LOG IN',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Register button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _showRegisterDialog(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF1B8E3D),
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(
                color: Color(0xFF1B8E3D),
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'REGISTER',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
