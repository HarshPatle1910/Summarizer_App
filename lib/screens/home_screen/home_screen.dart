import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:smart_summariser/consts/consts.dart';
import 'package:smart_summariser/screens/summary/summary_screen.dart';

import '../../controllers/auth_controllers.dart';
import '../auth_screen/login_screen.dart';
import '../history/history_screen.dart';
import '../profile/profile_screen.dart';
import 'feature_card.dart';

class HomeScreen extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  Future<DocumentSnapshot> fetchUserData() async {
    return FirebaseFirestore.instance.collection('users').doc(userId).get();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => authController.resetInactivityTimer(),
      child: SafeArea(
        child: Scaffold(
          body: FutureBuilder<DocumentSnapshot>(
            future: fetchUserData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child: Center(child: CircularProgressIndicator()));
              }

              if (snapshot.hasError) {
                return Center(
                    child: Column(
                  children: [
                    Text("Error: ${snapshot.error}"),
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
                              color: orangeColor,
                            ),
                          ),
                        ],
                      ),
                    ).onTap(() {
                      Get.to(LoginScreen());
                    }),
                  ],
                ));
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return Center(
                    child: Column(
                  children: [
                    Text("User data not found!"),
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
                              color: orangeColor,
                            ),
                          ),
                        ],
                      ),
                    ).onTap(() {
                      Get.to(LoginScreen());
                    }),
                  ],
                ));
              }

              var userData = snapshot.data!;
              String name = userData['name'] ?? 'User';
              String email = userData['email'] ?? 'No Email';
              String mobile = userData['mobile'] ?? 'No Mobile';

              return Container(
                color: Colors.white,
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.text_snippet, color: orangeColor),
                        SizedBox(width: 8),
                        Text(
                          appName,
                          style: TextStyle(
                            color: orangeColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        Spacer(),
                        CircleAvatar(
                          backgroundColor: lightGrey,
                          child: IconButton(
                            icon: Icon(Icons.person, color: orangeColor),
                            onPressed: () {
                              Get.to(() => ProfileScreen(
                                  name: name, email: email, mobile: mobile));
                            },
                          ),
                        ),
                      ],
                    ),

                    Divider(),

                    Text(
                      appThemeText,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),

                    Text(
                      appThemeTextMessage,
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 20),
                    // Buttons for New Summary and History
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Get.to(() => SummaryScreen());
                            },
                            icon: Icon(Icons.edit, color: Colors.white),
                            label: Text(
                              makeSummary,
                              style: TextStyle(
                                color: whiteColor,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: orangeColor,
                              padding: EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                              textStyle: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Get.to(() => HistoryPage());
                            },
                            icon: Icon(
                              Icons.history,
                              color: darkFontGrey,
                            ),
                            label: Text(
                              viewHistory,
                              style: TextStyle(
                                color: darkFontGrey,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: lightGrey,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              textStyle: TextStyle(
                                fontSize: 16,
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
                        .width(context.screenWidth)
                        .shadow
                        .make(),

                    SizedBox(height: 20),
                    // Session Timer
                    Obx(() {
                      int minutesLeft = authController.remainingTime.value;
                      return Text(
                        minutesLeft > 0
                            ? "Session expires in: $minutesLeft min"
                            : "Session expired! Logging out...",
                        style: TextStyle(
                          fontSize: 16,
                          color: minutesLeft > 5 ? Colors.green : Colors.red,
                        ),
                      );
                    }),

                    // SizedBox(height: 20),
                    Divider(),

                    // Features Section
                    Text(
                      features,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      // flex: 3,
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        children: [
                          FeatureCard(
                            icon: Icons.timer,
                            title: saveTime,
                            description: saveTimeDescription,
                          ),
                          FeatureCard(
                            icon: Icons.file_present,
                            title: multipleFormats,
                            description: multipleFormatsDescription,
                          ),
                          FeatureCard(
                            icon: Icons.security,
                            title: secure,
                            description: secureDescription,
                          ),
                          FeatureCard(
                            icon: Icons.smart_toy,
                            title: aiPowered,
                            description: aiPoweredDescription,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
