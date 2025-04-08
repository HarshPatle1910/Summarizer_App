// screens/admin_screen/admin_panel.dart
import 'package:get/get.dart';

import '../../consts/consts.dart';
import '../../controllers/admin_controller/admin_controller.dart';
import '../../controllers/auth_controllers.dart';
import '../auth_screen/login_screen.dart';

class AdminPanel extends StatelessWidget {
  final controller = Get.put(AdminController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Admin Panel",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: orangeColor,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Colors.black,
            ),
            tooltip: "Refresh",
            onPressed: () {
              controller.fetchUsers(); // Re-fetch user list
            },
          ),
          IconButton(
            icon: Icon(
              Icons.logout,
              color: Colors.black,
            ),
            tooltip: "Logout",
            onPressed: () async {
              Get.defaultDialog(
                title: "Confirm Logout",
                middleText: "Are you sure you want to log out?",
                textConfirm: "Logout",
                textCancel: "Cancel",
                confirmTextColor: whiteColor,
                buttonColor: orangeColor,
                onConfirm: () async {
                  Get.back();
                  await AuthController.instance.signoutMethod();
                  Get.offAll(() => LoginScreen());
                },
              );
            },
          ),
        ],
      ),
      body: Container(
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }

          if (controller.userList.isEmpty) {
            return Center(child: Text("No users found."));
          }

          return ListView.builder(
            itemCount: controller.userList.length,
            itemBuilder: (context, index) {
              var user = controller.userList[index];
              var createdAt =
                  user['created_at']?.toDate()?.toString().split(' ')?.first ??
                      "N/A";

              return Card(
                elevation: 3,
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(
                    user['name'] ?? 'No Name',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Email: ${user['email']}"),
                      Text("Mobile: ${user['mobile']}"),
                      Text("Password: ${user['password']}"),
                      Text("Created: $createdAt"),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: orangeColor),
                    onPressed: () {
                      Get.defaultDialog(
                        title: "Confirm Delete",
                        middleText:
                            "Are you sure you want to delete this user?",
                        textConfirm: "Delete",
                        textCancel: "Cancel",
                        confirmTextColor: whiteColor,
                        buttonColor: orangeColor,
                        onConfirm: () {
                          Get.back();
                          controller.deleteUser(user['id']);
                        },
                      );
                    },
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
