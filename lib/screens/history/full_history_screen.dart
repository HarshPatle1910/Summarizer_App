import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smart_summariser/consts/colors.dart';

import '../../consts/strings.dart' as state;

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
        const SnackBar(content: Text("No summarized text available to read!")),
      );
      return;
    }

    if (isSpeaking) {
      await flutterTts.stop();
      setState(() {
        isSpeaking = false;
      });
    } else {
      await flutterTts.speak(text);
      setState(() {
        isSpeaking = true;
      });

      flutterTts.setCompletionHandler(() {
        setState(() {
          isSpeaking = false;
        });
      });
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  var enteredTextLine = "\n\nEntered text:\n";
  var summaryLine = "\n\nSummary:\n";
  var summaryMode = "Summary mode:";

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(width: 2, color: orangeLightColor),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.copy,
                          color: darkFontGrey,
                        ),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(
                              text: summaryMode +
                                  widget.summary['selectedMode'] +
                                  enteredTextLine +
                                  widget.summary['enteredText'] +
                                  summaryLine +
                                  widget.summary['summarizedText']));
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(state.summaryCopieed)));
                        },
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(width: 2, color: orangeLightColor),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.share,
                          color: darkFontGrey,
                        ),
                        onPressed: () {
                          Share.share(summaryMode +
                              widget.summary['selectedMode'] +
                              enteredTextLine +
                              widget.summary['enteredText'] +
                              summaryLine +
                              widget.summary['summarizedText']);
                        },
                      ),
                    ),
                    Container(
                      // width: MediaQuery.of(context).size.width,
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
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5, // Slight shadow for depth
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                )
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
