import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../consts/consts.dart';
import '../screens/admin_panel/admin_screen.dart';
import '../screens/auth_screen/login_screen.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find();
  var isloading = false.obs;

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  // Text Controllers
  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  static const String _keyUserToken = "user_token";
  static const String _keyLastActivity = "last_activity";
  static const int sessionTimeoutMinutes = 60; // Session expires after 60 mins

  var remainingTime = 0.obs; // Observable for session countdown

  /// ************** LOGIN METHOD **************
  Future<UserCredential?> loginMethod({
    required String email,
    required String password,
    required context,
  }) async {
    UserCredential? userCredential;

    try {
      // Admin bypass
      if (email == 'admin@gmail.com' && password == 'Admin@7890') {
        VxToast.show(context, msg: 'Admin Logged In');
        Get.offAll(() => AdminPanel()); // Make sure to import it
        return null;
      }

      // Regular user login
      userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await saveSession(userCredential.user!.uid);
      startSessionTimer(); // Start session timer after login
      return userCredential;
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Login Failed", e.message ?? "An error occurred");
    }
    return null;
  }

  /// ************** SIGNUP METHOD **************
  Future<UserCredential?> signupMethod({
    required String name,
    required String email,
    required String mobile,
    required String password,
    required BuildContext context,
  }) async {
    UserCredential? userCredential;

    try {
      userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // String hashedPassword = hashPassword(password);

      await storeUserData(
        name: name,
        email: email,
        password: password,
        mobile: mobile,
        userId: userCredential.user!.uid,
      );

      await saveSession(userCredential.user!.uid);
      startSessionTimer();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Signup Failed", e.message ?? "An error occurred");
    }
    return null;
  }

  /// ************** HASH PASSWORD **************
  String hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// ************** STORE USER DATA **************
  Future<void> storeUserData({
    required String userId,
    required String name,
    required String email,
    required String password,
    required String mobile,
  }) async {
    DocumentReference store = firestore.collection("users").doc(userId);

    await store.set({
      'id': userId,
      'name': name,
      'email': email,
      'password': password,
      'mobile': mobile,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  /// ************** SAVE SESSION **************
  Future<void> saveSession(String userId) async {
    await secureStorage.write(key: _keyUserToken, value: userId);
    await _updateLastActivity();
  }

  /// ************** CHECK SESSION **************
  Future<bool> isSessionActive() async {
    String? userId = await secureStorage.read(key: _keyUserToken);
    if (userId == null) return false;

    int? lastActivity = await _getLastActivity();
    if (lastActivity == null) return false;

    int currentTime = DateTime.now().millisecondsSinceEpoch;
    int elapsedMinutes = (currentTime - lastActivity) ~/ (1000 * 60);

    return elapsedMinutes < sessionTimeoutMinutes;
  }

  /// ************** SESSION TIMER **************
  void startSessionTimer() {
    Timer.periodic(Duration(seconds: 1), (timer) async {
      int? lastActivity = await _getLastActivity();
      if (lastActivity == null) {
        remainingTime.value = 0;
        timer.cancel();
        signoutMethod();
        return;
      }

      int currentTime = DateTime.now().millisecondsSinceEpoch;
      int elapsedMinutes = (currentTime - lastActivity) ~/ (1000 * 60);
      int timeLeft = sessionTimeoutMinutes - elapsedMinutes;

      if (timeLeft <= 0) {
        remainingTime.value = 0;
        timer.cancel();
        signoutMethod();
      } else {
        remainingTime.value = timeLeft;
      }
    });
  }

  /// ************** RESET INACTIVITY TIMER **************
  Future<void> resetInactivityTimer() async {
    await _updateLastActivity();
  }

  /// ************** UPDATE LAST ACTIVITY **************
  Future<void> _updateLastActivity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLastActivity, DateTime.now().millisecondsSinceEpoch);
  }

  /// ************** GET LAST ACTIVITY **************
  Future<int?> _getLastActivity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyLastActivity);
  }

  /// ************** SIGN OUT **************
  Future<void> signoutMethod() async {
    try {
      await auth.signOut();
      await secureStorage.delete(key: _keyUserToken);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyLastActivity);
      emailController.text = '';
      passwordController.text = '';
      isloading.value = false;
      Get.offAll(() => LoginScreen());
    } on FirebaseAuthException catch (e) {
      print("❌ Sign Out Failed: ${e.message}");
    }
  }
  //
  // Future<void> resetPassword(String email, BuildContext context) async {
  //   try {
  //     await auth.sendPasswordResetEmail(email: email);
  //     Get.snackbar("Success", "Password reset link sent to $email",
  //         backgroundColor: orangeColor, colorText: whiteColor);
  //   } on FirebaseAuthException catch (e) {
  //     Get.snackbar("Error", e.message ?? "Something went wrong",
  //         backgroundColor: Colors.red, colorText: whiteColor);
  //   }
  // }
}
