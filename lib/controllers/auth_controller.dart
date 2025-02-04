import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:trenord/utils/ui_utils.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Rx<User?> user = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    user.value = _auth.currentUser;
    // ever(user, _setInitialScreen);
    _auth.authStateChanges().listen((User? user) {
      this.user.value = user;
    });
  }
  void _setInitialScreen(User? user) {
  }
  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      UIUtils.showSuccess('Success', 'Login successful');
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Email is not registered';
          break;
        case 'wrong-password':
          message = 'Wrong password';
          break;
        case 'invalid-email':
          message = 'Invalid Email format';
          break;
        default:
          message = 'Login failed. Please try again';
      }
      UIUtils.showError('Error', message);
    } catch (e) {
      UIUtils.showError('Error', 'Login failed. Please try again');
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      UIUtils.showSuccess('Success', 'Registration successful');
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'Password must be at least 6 characters';
          break;
        case 'email-already-in-use':
          message = 'Email is already registered';
          break;
        case 'invalid-email':
          message = 'Invalid Email format';
          break;
        default:
          message = 'Registration failed. Please try again';
      }
      UIUtils.showError('Error', message);
    } catch (e) {
      UIUtils.showError('Error', 'Registration failed. Please try again');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      UIUtils.showSuccess('Success', 'Logged out successfully.');
    } catch (e) {
      UIUtils.showError('Error', 'Logout failed.');
    }
  }
} 