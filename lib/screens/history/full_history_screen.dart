import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import 'package:smart_summariser/consts/colors.dart';

class FullHistoryScreen extends StatefulWidget {
  final Map<String, dynamic> summary;

  const FullHistoryScreen({required this.summary, Key? key}) : super(key: key);

  @override
  _FullHistoryScreenState createState() => _FullHistoryScreenState();
}

class _FullHistoryScreenState extends State<FullHistoryScreen> {
  final FlutterTts flutterTts = FlutterTts();
  bool isSpeaking = false;

  Future<void> _toggleSpeech() async {
    String text = widget.summary['summarizedText'] ?? 'N/A';

    if (text.isEmpty || text == 'N/A') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No summarized text available to read!")),
      );
      return;
    }

    if (isSpeaking) {
      setState(() async {
        isSpeaking = false;
        await flutterTts.stop();
      });
    } else {
      setState(() async {
        isSpeaking = true;
        await flutterTts.speak(text);
      });
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          "Summary Mode: ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(widget.summary['selectedMode'] ?? 'N/A'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Created At: ',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87),
                        ),
                        Text(
                          _formatTimestamp(widget.summary['timestamp']),
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ],
                    ),
                  ],
                ),
                Divider(),
                const Text(
                  'Original Text:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.summary['enteredText'] ?? 'N/A',
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const Divider(height: 32, thickness: 1.5),
                const Text(
                  'Summarized Text:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.summary['summarizedText'] ?? 'N/A',
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 10),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton.icon(
                    onPressed: _toggleSpeech,
                    icon: Icon(
                      isSpeaking ? Icons.stop : Icons.volume_up,
                      color: Colors.black,
                    ),
                    label: Text(
                      isSpeaking ? "Stop Listening" : "Listen Summary",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orangeColor,
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5, // Slight shadow for depth
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    final DateTime dateTime = timestamp.toDate();
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return formatter.format(dateTime);
  }
}
