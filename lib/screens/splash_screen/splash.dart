import 'package:get/get.dart';

import '../../consts/consts.dart';
import '../../controllers/auth_controllers.dart';
import '../../widgets_common/applogo_widgets.dart';
import '../auth_screen/signup_screen.dart';
import '../home_screen/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _handleAutoLogin();
  }

  /// Check session and navigate accordingly
  void _handleAutoLogin() async {
    await Future.delayed(
      const Duration(seconds: 5),
    ); // Show splash screen for 5 sec

    bool sessionActive = await AuthController.instance.isSessionActive();

    if (sessionActive) {
      Get.offAll(
        () => const HomeScreen(),
      ); // Go to HomeScreen if session is active
    } else {
      Get.offAll(
        () => const SignUpScreen(),
      ); // Go to SignUpScreen if no active session
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: redColor,
      body: Center(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Image.asset(icSplashBg, width: 300),
            ),
            20.heightBox,
            appLogoWidget(),
            10.heightBox,
            Text(
              appname,
              style: TextStyle(
                fontFamily: bold,
                fontSize: 34,
                color: Colors.white,
              ),
            ),
            appversion.text.white.make(),
            Spacer(),
            credits.text.white.fontFamily(semibold).make(),
            HeightBox(30),
          ],
        ),
      ),
    );
  }
}
