import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:smart_summariser/screens/auth_screen/login_screen.dart';

import '../../consts/consts.dart';
import '../../widgets_common/costum_textfield.dart';
import '../../widgets_common/our_button.dart';

class ResetPasswordScreen extends StatelessWidget {
  final String phone;
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  ResetPasswordScreen({required this.phone});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Reset Password")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            costumTextField(
              title: "New Password",
              hint: "Enter new password",
              ispass: true,
              controller: passwordController,
            ),
            costumTextField(
              title: "Confirm Password",
              hint: "Confirm new password",
              ispass: true,
              controller: confirmController,
            ),
            20.heightBox,
            ourButton(
              onPress: () async {
                String pass = passwordController.text.trim();
                String confirm = confirmController.text.trim();

                if (pass.length < 6) {
                  Get.snackbar(
                      "Error", "Password must be at least 6 characters");
                  return;
                }

                if (pass != confirm) {
                  Get.snackbar("Error", "Passwords do not match");
                  return;
                }

                try {
                  // Hash the password for Firestore
                  var bytes = utf8.encode(pass);
                  var hashedPassword = sha256.convert(bytes).toString();

                  // Query user by phone number
                  var query = await FirebaseFirestore.instance
                      .collection("users")
                      .where("mobile", isEqualTo: phone)
                      .limit(1)
                      .get();

                  if (query.docs.isNotEmpty) {
                    var userDoc = query.docs.first.reference;
                    var userEmail = query.docs.first.get("email");

                    // Update hashed password in Firestore
                    await userDoc.update({"password": hashedPassword});

                    // Try updating Firebase Auth password if user is signed in
                    var currentUser = FirebaseAuth.instance.currentUser;

                    if (currentUser != null) {
                      await currentUser.updatePassword(pass);
                    } else {
                      // If not signed in, send a reset email (optional fallback)
                      if (userEmail != null &&
                          userEmail.toString().isNotEmpty) {
                        await FirebaseAuth.instance
                            .sendPasswordResetEmail(email: userEmail);
                        Get.snackbar("Info",
                            "Password updated in database.\nReset link sent to $userEmail to update Firebase authentication password.");
                      }
                    }

                    Get.offAll(() => LoginScreen());
                    Get.snackbar("Success", "Password reset successfully!");
                  } else {
                    Get.snackbar(
                        "Error", "User not found with this phone number");
                  }
                } catch (e) {
                  Get.snackbar("Error", "Failed to update password: $e");
                }
              },
              color: orangeColor,
              textColor: whiteColor,
              title: resetPassword,
            ),
          ],
        ),
      ),
    );
  }
}
