import 'package:get/get.dart';

import '../../consts/consts.dart';
import '../../controllers/auth_controllers.dart';
import '../../widgets_common/applogo_widgets.dart';
import '../../widgets_common/bg_widget.dart';
import '../../widgets_common/costum_textfield.dart';
import '../../widgets_common/our_button.dart';
import '../home_screen/home_screen.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool? isCheck = false;
  var controller = Get.put(AuthController());

  //TextEditing Controllers
  var nameController = TextEditingController();
  var emailController = TextEditingController();
  var mobileController = TextEditingController(); // Added mobile number field
  var passwordController = TextEditingController();
  var passwordRetypeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BgWidget(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                (context.screenHeight * 0.1).heightBox,
                appLogoWidget(),
                10.heightBox,
                "Join the $appname".text.fontFamily(bold).white.size(16).make(),
                20.heightBox,
                Obx(
                  () => Column(
                    children: [
                      costumTextField(
                        title: name,
                        hint: nameHint,
                        controller: nameController,
                        ispass: false,
                      ),
                      costumTextField(
                        title: mail,
                        hint: mailHint,
                        controller: emailController,
                        ispass: false,
                      ),
                      costumTextField(
                        title: mobileNumber,
                        hint: mobileNumberHint,
                        controller: mobileController,
                        ispass: false,
                      ),
                      costumTextField(
                        title: password,
                        hint: passwordHint,
                        controller: passwordController,
                        ispass: true,
                      ),
                      costumTextField(
                        title: confirmPassword,
                        hint: passwordHint,
                        controller: passwordRetypeController,
                        ispass: true,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: forgetpassword.text.make(),
                        ),
                      ),
                      5.heightBox,
                      Row(
                        children: [
                          Checkbox(
                            value: isCheck,
                            onChanged: (newvalue) {
                              setState(() {
                                isCheck = newvalue;
                              });
                            },
                          ),
                          Expanded(
                            child: RichText(
                              text: const TextSpan(
                                children: [
                                  TextSpan(
                                    text: "I agree to the ",
                                    style: TextStyle(
                                      fontFamily: regular,
                                      color: fontGrey,
                                    ),
                                  ),
                                  TextSpan(
                                    text: termsAndCondition,
                                    style: TextStyle(
                                      fontFamily: regular,
                                      color: redColor,
                                    ),
                                  ),
                                  TextSpan(
                                    text: " & ",
                                    style: TextStyle(
                                      fontFamily: regular,
                                      color: fontGrey,
                                    ),
                                  ),
                                  TextSpan(
                                    text: privacy,
                                    style: TextStyle(
                                      fontFamily: regular,
                                      color: redColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      5.heightBox,
                      controller.isloading.value
                          ? CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(
                                redColor,
                              ),
                            )
                          : ourButton(
                              onPress: () async {
                                if (!isValidEmail(emailController.text)) {
                                  VxToast.show(
                                    context,
                                    msg: "Enter a valid email.",
                                  );
                                } else if (!isValidMobile(
                                  mobileController.text,
                                )) {
                                  VxToast.show(
                                    context,
                                    msg: "Enter a valid mobile number.",
                                  );
                                } else if (!isValidPassword(
                                  passwordController.text,
                                )) {
                                  VxToast.show(
                                    context,
                                    msg: "Enter a strong password.",
                                  );
                                } else if (!isPasswordMatch(
                                  passwordController.text,
                                  passwordRetypeController.text,
                                )) {
                                  VxToast.show(
                                    context,
                                    msg: "Passwords do not match.",
                                  );
                                } else if (isCheck == true) {
                                  controller.isloading(true);
                                  try {
                                    await controller
                                        .signupMethod(
                                      name: nameController.text,
                                      context: context,
                                      email: emailController.text,
                                      mobile: mobileController
                                          .text, // Added mobile number
                                      password: passwordController.text,
                                    )
                                        .then((value) {
                                      VxToast.show(
                                        context,
                                        msg: "Signed up successfully!",
                                      );
                                      Get.offAll(() => HomeScreen());
                                    });
                                  } catch (e) {
                                    auth.signOut();
                                    VxToast.show(
                                      context,
                                      msg: e.toString(),
                                    );
                                    controller.isloading(false);
                                  }
                                } else {
                                  VxToast.show(
                                    context,
                                    msg: "Please accept terms and conditions.",
                                  );
                                }
                              },
                              color: isCheck == true ? redColor : lightGrey,
                              textColor: whiteColor,
                              title: signup,
                            ).box.width(context.screenWidth - 50).make(),
                      5.heightBox,
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: alreadyHaveAnAccount,
                              style: TextStyle(
                                fontFamily: bold,
                                color: fontGrey,
                              ),
                            ),
                            TextSpan(
                              text: login,
                              style: TextStyle(
                                fontFamily: bold,
                                color: redColor,
                              ),
                            ),
                          ],
                        ),
                      ).onTap(() {
                        Get.to(LoginScreen());
                      }),
                    ],
                  )
                      .box
                      .white
                      .rounded
                      .padding(EdgeInsets.all(16))
                      .width(context.screenWidth - 70)
                      .shadow
                      .make(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool isValidEmail(String email) {
    RegExp regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email);
  }

  bool isValidMobile(String mobile) {
    RegExp regex = RegExp(r'^\d{10}$'); // Ensures exactly 10 digits
    return regex.hasMatch(mobile);
  }

  bool isValidPassword(String password) {
    RegExp regex = RegExp(r'^(?=.*[A-Z])(?=.*[!@#\$%^&*(),.?":{}|<>]).{8,}$');
    return regex.hasMatch(password);
  }

  bool isPasswordMatch(String password, String confirmPassword) {
    return password == confirmPassword;
  }
}
