import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  final isLoading = false.obs;

  Future<bool> register({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;

      await _authService.register(email: email, password: password);

      return true;
    } catch (e) {
      _showAuthError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    try {
      isLoading.value = true;

      await _authService.login(email: email, password: password);

      return true;
    } catch (e) {
      _showAuthError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      _showAuthError(e);
    }
  }

  Future<bool> forgotPassword(String email) async {
    try {
      isLoading.value = true;

      await _authService.sendPasswordResetEmail(email.trim());

      Get.snackbar('Success', 'Password reset email sent.');

      return true;
    } catch (e) {
      _showAuthError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void _showAuthError(Object error) {
    String message = 'Something went wrong. Please try again.';

    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;

        case 'user-not-found':
          message = 'No account found with this email.';
          break;

        case 'wrong-password':
        case 'invalid-credential':
          message = 'Incorrect email or password.';
          break;

        case 'email-already-in-use':
          message = 'An account already exists with this email.';
          break;

        case 'weak-password':
          message = 'Password is too weak.';
          break;

        case 'user-disabled':
          message = 'This account has been disabled.';
          break;

        case 'network-request-failed':
          message = 'Please check your internet connection.';
          break;

        default:
          message = error.message ?? message;
      }
    }

    Get.snackbar('Authentication Error', message);
  }
}
