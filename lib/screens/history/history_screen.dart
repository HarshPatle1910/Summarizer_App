import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smart_summariser/screens/history/full_history_screen.dart';

import '../../consts/consts.dart';

class HistoryController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RxList<Map<String, dynamic>> historyList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchHistory();
  }

  void fetchHistory() async {
    try {
      final snapshot = await _firestore.collection('summaries').get();
      historyList.value = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch history: $e');
    }
  }

  void deleteSummary(String id) async {
    try {
      await _firestore.collection('summaries').doc(id).delete();
      fetchHistory(); // Refresh the list
      Get.snackbar('Success', 'Summary deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete summary: $e');
    }
  }

  void editSummary(String id, String newText) async {
    try {
      await _firestore.collection('summaries').doc(id).update({
        'summarizedText': newText,
      });
      fetchHistory(); // Refresh the list
      Get.snackbar('Success', 'Summary updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to edit summary: $e');
    }
  }
}

class HistoryPage extends StatelessWidget {
  final HistoryController controller = Get.put(HistoryController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: orangeColor,
        title: const Text(
          'History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Obx(
        () => controller.historyList.isEmpty
            ? const Center(
                child: Text('No history available'),
              )
            : ListView.builder(
                itemCount: controller.historyList.length,
                itemBuilder: (context, index) {
                  final item = controller.historyList[index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Original Text:',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${item['enteredText']}',
                                maxLines: 5,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Text(
                            'Summarized Text:',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text('${item['summarizedText']}', maxLines: 3),
                          Divider(),
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Summary Mode: ",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text("${item['selectedMode']}"),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    'Time:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    ' ${_formatTimestamp(item['timestamp'])}',
                                  ),
                                ],
                              ),
                              Spacer(),
                              IconButton(
                                icon: const Icon(Icons.open_in_full_rounded,
                                    color: Colors.green),
                                onPressed: () {
                                  Get.to(
                                      () => FullHistoryScreen(summary: item));
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  _showEditDialog(context, item['id'],
                                      item['summarizedText']);
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  controller.deleteSummary(item['id']);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, String id, String currentText) {
    final TextEditingController textController =
        TextEditingController(text: currentText);

    Get.defaultDialog(
      title: 'Edit Summary',
      content: Column(
        children: [
          TextField(
            controller: textController,
            decoration: const InputDecoration(hintText: 'Enter new text'),
            maxLines: 3,
          ),
        ],
      ),
      confirm: ElevatedButton(
        onPressed: () {
          controller.editSummary(id, textController.text);
          Get.back();
        },
        child: const Text('Save'),
      ),
      cancel: TextButton(
        onPressed: () {
          Get.back();
        },
        child: const Text('Cancel'),
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final DateTime dateTime =
        timestamp.toDate(); // Convert Timestamp to DateTime
    final DateFormat formatter =
        DateFormat('yyyy-MM-dd HH:mm:ss'); // Format the date and time
    return formatter.format(dateTime); // Return formatted date and time
  }
}
