// controllers/admin_controller/admin_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class AdminController extends GetxController {
  var isLoading = false.obs;
  var userList = [].obs;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    isLoading.value = true;

    try {
      final snapshot = await firestore.collection('users').get();
      userList.assignAll(snapshot.docs.map((e) => e.data()).toList());
    } catch (e) {
      print('Error fetching users: $e');
    }

    isLoading.value = false;
  }

  Future<void> deleteUser(String userId) async {
    isLoading.value = true;

    try {
      // Delete from summaries collection
      final summariesSnapshot = await firestore
          .collection('summaries')
          .where('user_id', isEqualTo: userId)
          .get();

      for (var doc in summariesSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete from users collection
      await firestore.collection('users').doc(userId).delete();

      // Refresh the user list
      fetchUsers();

      Get.snackbar("Success", "User deleted successfully",
          snackPosition: SnackPosition.TOP);
    } catch (e) {
      Get.snackbar("Error", "Failed to delete user",
          snackPosition: SnackPosition.TOP);
    }

    isLoading.value = false;
  }
}
