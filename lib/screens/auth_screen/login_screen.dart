import 'package:get/get.dart';
import 'package:smart_summariser/screens/auth_screen/signup_screen.dart';

import '../../consts/consts.dart';
import '../../controllers/auth_controllers.dart';
import '../../widgets_common/applogo_widgets.dart';
import '../../widgets_common/bg_widget.dart';
import '../../widgets_common/costum_textfield.dart';
import '../../widgets_common/our_button.dart';
import '../home_screen/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController controller = Get.put(AuthController());

  final List<String> socialListIcon = [
    "assets/icons/google_logo.png",
    "assets/icons/facebook_logo.png",
    "assets/icons/twitter_logo.png",
  ];

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
                "Log in to $appname"
                    .text
                    .fontFamily(bold)
                    .white
                    .size(16)
                    .make(),
                20.heightBox,
                Obx(
                  () => Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      costumTextField(
                        title: mail,
                        hint: mailHint,
                        ispass: false,
                        controller: controller.emailController,
                      ),
                      costumTextField(
                        title: password,
                        hint: passwordHint,
                        ispass: true,
                        controller: controller.passwordController,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: forgetpassword.text.make(),
                        ),
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
                                controller.isloading(true);
                                try {
                                  final user = await controller.loginMethod(
                                    context: context,
                                    email:
                                        controller.emailController.text.trim(),
                                    password: controller.passwordController.text
                                        .trim(),
                                  );
                                  if (user != null) {
                                    VxToast.show(context, msg: loggedIn);
                                    Get.offAll(() => const HomeScreen());
                                  }
                                } catch (e) {
                                  VxToast.show(
                                    context,
                                    msg: e.toString(),
                                  );
                                }
                                controller.isloading(false);
                              },
                              color: redColor,
                              textColor: whiteColor,
                              title: login,
                            ).box.width(context.screenWidth - 50).make(),
                      5.heightBox,
                      createNewAccount.text.color(fontGrey).make(),
                      5.heightBox,
                      ourButton(
                        onPress: () {
                          Get.to(() => const SignUpScreen());
                        },
                        color: lightGrey,
                        textColor: redColor,
                        title: signup,
                      ).box.width(context.screenWidth - 50).make(),
                      10.heightBox,
                      loginwith.text.color(fontGrey).make(),
                      5.heightBox,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          socialListIcon.length,
                          (index) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              backgroundColor: lightGrey,
                              radius: 25,
                              child: Image.asset(
                                socialListIcon[index],
                                width: 25,
                              ),
                            ),
                          ),
                        ),
                      ),
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
}
