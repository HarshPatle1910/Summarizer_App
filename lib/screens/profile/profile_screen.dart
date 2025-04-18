import 'package:get/get.dart';

import '../../consts/consts.dart';
import '../../controllers/auth_controllers.dart';
import '../../widgets_common/our_button.dart';
import '../about_app_screen/about_app_screen.dart';
import '../history/history_screen.dart';
import '../privacy_policy/privacy_policy_screen.dart';
import '../review_screen/review_screen.dart';
import '../terms_of_services/terms_of_services.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen(
      {super.key,
      required this.name,
      required this.email,
      required this.mobile});

  final String name, email, mobile;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildProfileHeader(),
                  SizedBox(height: 16),
                  _buildUserDetails(),
                  Divider(),
                  _buildMenuItems(context),
                  SizedBox(height: 16), // Spacer replacement
                  _buildHistoryButton(context),
                  SizedBox(height: 10),
                  _buildLogoutButton(context),
                ],
              )
                  .box
                  .white
                  .rounded
                  .padding(EdgeInsets.all(16))
                  .width(context.screenWidth)
                  .shadow
                  .make(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CircleAvatar(radius: 30, backgroundImage: AssetImage(icUserLogo)),
        SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome, ",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text("$name!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildUserDetails() {
    return Text(
      "Hey $name! We're glad to have you here. Your registered email is $email, and we can reach you at $mobile. Stay connected and explore more features!",
      textAlign: TextAlign.start,
      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    List<Map<String, dynamic>> menuItems = [
      {
        'icon': Icons.settings,
        'title': 'Settings',
        'route': () {
          // Example: open Play Store link or show dialog
          print("Redirect to Play Store");
        },
      },
      {
        'icon': Icons.privacy_tip_rounded,
        'title': 'Privacy & Policy',
        'route': () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => PrivacyPolicyScreen())),
      },
      {
        'icon': Icons.home_repair_service_rounded,
        'title': 'Terms of Services',
        'route': () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => TermsOfServiceScreen())),
      },
      {
        'icon': Icons.info,
        'title': 'About App',
        'route': () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => AboutAppScreen())),
      },
      {
        'icon': Icons.rate_review,
        'title': 'Review & Rate Us',
        'route': () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => ReviewsScreen())),
      },
      {
        'icon': Icons.reviews,
        'title': 'Users Reviews',
        'route': () {
          // Example: open Play Store link or show dialog
          print("Redirect to Play Store");
        },
      },
      {
        'icon': Icons.mobile_screen_share,
        'title': 'Share with Friends',
        'route': () {
          // Example: use Share plugin
          print("Share the app");
        },
      },
      {
        'icon': Icons.install_mobile,
        'title': 'More Apps',
        'route': () {
          // Example: redirect to developer page
          print("Open More Apps");
        },
      },
    ];

    return Column(
      children: menuItems
          .map((item) =>
              _buildMenuItem(item['icon'], item['title'], item['route']))
          .toList(),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: Colors.black),
            SizedBox(width: 10),
            Text(title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Spacer(),
            Icon(Icons.keyboard_arrow_right),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => HistoryPage()),
      child: Container(
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          border: Border.all(width: 2, color: orangeLightColor),
        ),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Text(history, style: TextStyle(color: Colors.black)),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return ourButton(
      onPress: () => AuthController.instance.signoutMethod(),
      color: orangeColor,
      textColor: whiteColor,
      title: logout,
    ).box.rounded.width(context.screenWidth).make();
  }
}
