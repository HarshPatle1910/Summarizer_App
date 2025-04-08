// controllers/forgot_password_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController {
  var emailController = TextEditingController();
  var isLoading = false.obs;
  var recoveredPassword = "".obs;
  var statusMessage = "".obs;

  Future<void> recoverPassword() async {
    String email = emailController.text.trim();
    recoveredPassword.value = "";
    statusMessage.value = "";

    if (email.isEmpty || !email.contains('@')) {
      statusMessage.value = "Please enter a valid email address.";
      return;
    }

    isLoading(true);
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var data = snapshot.docs.first.data();
        String hashedPassword = data['password'];
        recoveredPassword.value = hashedPassword;
        statusMessage.value = "Recovered password:";
      } else {
        statusMessage.value = "No user found with this email.";
      }
    } catch (e) {
      statusMessage.value = "Something went wrong: $e";
    } finally {
      isLoading(false);
    }
  }
}
