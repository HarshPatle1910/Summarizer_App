import 'package:get/get.dart';

import '../../consts/consts.dart';
import '../../controllers/auth_controllers.dart';
import '../../widgets_common/our_button.dart';
import '../history/history_screen.dart';

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
                  _buildMenuItems(),
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

  Widget _buildMenuItems() {
    List<Map<String, dynamic>> menuItems = [
      {'icon': Icons.settings, 'title': 'Settings'},
      {'icon': Icons.privacy_tip_rounded, 'title': 'Privacy & Policy'},
      {'icon': Icons.home_repair_service_rounded, 'title': 'Terms of Services'},
      {'icon': Icons.info, 'title': 'About App'},
      {'icon': Icons.reviews, 'title': 'Reviews'},
      {'icon': Icons.rate_review, 'title': 'Rate Us'},
      {'icon': Icons.mobile_screen_share, 'title': 'Share with Friends'},
      {'icon': Icons.install_mobile, 'title': 'More Apps'},
    ];

    return Column(
      children: menuItems
          .map((item) => _buildMenuItem(item['icon'], item['title']))
          .toList(),
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return GestureDetector(
      onTap: () => Get.snackbar(title, '$title page coming soon!',
          snackPosition: SnackPosition.TOP),
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
        child: Text(viewHistory, style: TextStyle(color: Colors.black)),
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
