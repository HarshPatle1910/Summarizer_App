// screens/auth_screen/forgot_password_screen.dart
import 'package:get/get.dart';

import '../../consts/consts.dart';
import '../../controllers/forgot_password_controller.dart';
import '../../widgets_common/costum_textfield.dart';
import '../../widgets_common/our_button.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final ForgotPasswordController controller =
      Get.put(ForgotPasswordController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Forgot Password")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            costumTextField(
              title: "Email",
              hint: "Enter your registered email",
              ispass: false,
              controller: controller.emailController,
            ),
            const SizedBox(height: 20),
            Obx(() => controller.isLoading.value
                ? const CircularProgressIndicator()
                : Container(
                    width: MediaQuery.of(context).size.width,
                    child: ourButton(
                      onPress: () {
                        controller.recoverPassword();
                      },
                      color: orangeColor,
                      textColor: whiteColor,
                      title: "Recover Password",
                    ),
                  )),
            const SizedBox(height: 20),
            Obx(() => Column(
                  children: [
                    if (controller.statusMessage.isNotEmpty)
                      Text(
                        controller.statusMessage.value,
                        style: TextStyle(
                          color: controller.recoveredPassword.isNotEmpty
                              ? fontGrey
                              : Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    if (controller.recoveredPassword.isNotEmpty)
                      Text(
                        controller.recoveredPassword.value,
                        style: TextStyle(
                          color: darkFontGrey,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
