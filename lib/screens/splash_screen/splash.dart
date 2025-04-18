import 'package:get/get.dart';
import 'package:smart_summariser/screens/auth_screen/login_screen.dart';

import '../../consts/consts.dart';
import '../../controllers/auth_controllers.dart';
import '../../widgets_common/applogo_widgets.dart';
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
        () => HomeScreen(),
      ); // Go to HomeScreen if session is active
    } else {
      Get.offAll(
        () => const LoginScreen(),
      ); // Go to SignUpScreen if no active session
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: orangeColor,
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
              appName,
              style: TextStyle(
                fontFamily: bold,
                fontSize: 34,
                color: Colors.white,
              ),
            ),
            appVersion.text.white.make(),
            Spacer(),
            credits.text.white.fontFamily(semibold).make(),
            HeightBox(30),
          ],
        ),
      ),
    );
  }
}
