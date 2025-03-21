import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../consts/consts.dart';
import '../../controllers/auth_controllers.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userId = FirebaseAuth.instance.currentUser!.uid;
  late Future<DocumentSnapshot> userFuture;

  @override
  void initState() {
    super.initState();
    AuthController.instance.resetInactivityTimer(); // Reset session timer
    AuthController.instance.startSessionTimer();
    userFuture = fetchUserData(); // Fetch user data from Firestore
  }

  /// Fetch user data from Firestore
  Future<DocumentSnapshot> fetchUserData() async {
    return FirebaseFirestore.instance.collection('users').doc(userId).get();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => AuthController.instance.resetInactivityTimer(),
      child: SafeArea(
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder<DocumentSnapshot>(
              future: userFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator()); // Loading
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text("Error: ${snapshot.error}"),
                  ); // Error
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Center(child: Text("User data not found!")); // No data
                }

                // Extract user details
                var userData = snapshot.data!;
                String name = userData['name'] ?? 'User';
                String email = userData['email'] ?? 'No Email';
                String mobile = userData['mobile'] ?? 'No Mobile';
                // String? profileImage = userData['profileImage']; // Optional

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Profile Image
                    CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          AssetImage(icUserLogo) as ImageProvider, // Default
                    ),
                    SizedBox(height: 16),

                    // Welcome Message
                    Text(
                      // "Welcome, $name!",
                      welcome + " $name!",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),

                    // User Details in a Paragraph Format
                    Text(
                      "Hey $name! We're glad to have you here." +
                          " Your registered email is $email," +
                          " and we can reach you at $mobile." +
                          " Stay connected and explore more features!",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    SizedBox(height: 30),
                    Obx(() {
                      int minutesLeft =
                          AuthController.instance.remainingTime.value;
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

                    SizedBox(height: 30),

                    // Logout Button
                    ElevatedButton(
                      onPressed: () {
                        AuthController.instance.signoutMethod();
                      },
                      child: Text("Logout"),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
