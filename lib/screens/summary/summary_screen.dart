import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smart_summariser/consts/consts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../../bloc/summary/summary_bloc.dart';
import '../../bloc/summary/summary_event.dart';
import '../../bloc/summary/summary_state.dart';

class SummaryScreen extends StatefulWidget {
  @override
  _SummaryScreenState createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final TextEditingController _controller = TextEditingController();
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  bool _isListening = false;
  bool _isPlaying = false;
  String _selectedMode = "Extractive"; // Default mode

  // String _extractedText = "";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();

    _flutterTts.setLanguage("en-US");
    _flutterTts.setPitch(1.0);
    _flutterTts.setSpeechRate(0.5);
    _flutterTts.awaitSpeakCompletion(true);

    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isPlaying = false;
      });
    });
  }

  void _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(onResult: (result) {
        setState(() {
          _controller.text = result.recognizedWords;
          _isPlaying = false;
        });
      });
    }
  }

  void _stopListening() {
    setState(() => _isListening = false);
    _speech.stop();
  }

  void toggleSpeech(String text) async {
    if (_isPlaying) {
      await _flutterTts.stop();
      setState(() {
        _isPlaying = false;
      });
    } else {
      if (text.isNotEmpty) {
        await _flutterTts.speak(text);
        setState(() {
          _isPlaying = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No summary available to speak")),
        );
      }
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null) {
      String? path = result.files.single.path;
      if (path != null) {
        if (path.endsWith(".pdf")) {
          await _extractTextFromPDF(File(path));
        } else if (path.endsWith(".jpg") || path.endsWith(".png")) {
          await _extractTextFromImage(File(path));
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Unsupported file type!")));
        }
      }
    }
  }

  Future<void> _extractTextFromPDF(File file) async {
    try {
      final PdfDocument document =
          PdfDocument(inputBytes: await file.readAsBytes());
      String text = PdfTextExtractor(document).extractText();
      setState(() => _controller.text = text);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error reading PDF")));
    }
  }

  Future<void> _extractTextFromImage(File file) async {
    final inputImage = InputImage.fromFile(file);
    final textDetector = GoogleMlKit.vision.textRecognizer();
    final RecognizedText recognizedText =
        await textDetector.processImage(inputImage);
    setState(() => _controller.text = recognizedText.text);
    textDetector.close();
  }

  Future<void> _saveToFirestore(
      String enteredText, String summarizedText, String selectedMode) async {
    try {
      // Get the current user
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Prepare the data to be saved
        final data = {
          'enteredText': enteredText,
          'summarizedText': summarizedText,
          'timestamp': DateTime.now(),
          'userId': user.uid,
          'email': user.email,
          'selectedMode': selectedMode
        };

        // Save the data to Firestore
        await FirebaseFirestore.instance.collection('summaries').add(data);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Summary saved successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User not logged in")),
        );
      }
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save summary: $e")),
      );
    }
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
              children: [
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(width: 4, color: orangeLightColor),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        maxLines: 8,
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Enter text to summarize',
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        // color: orangeLightColor,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                child: IconButton(
                                  icon: Icon(
                                    // size: 20,
                                    _isListening ? Icons.mic_off : Icons.mic,
                                    color: _isListening
                                        ? Colors.grey
                                        : darkFontGrey,
                                  ),
                                  onPressed: _isListening
                                      ? _stopListening
                                      : _startListening,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      width: 2, color: orangeLightColor),
                                ),
                              ),
                              GestureDetector(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        width: 2, color: orangeLightColor),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 15),
                                  child: Text(
                                    "Pick PDF/Image File",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                                onTap: _pickFile,
                              ),
                              GestureDetector(
                                  onTap: () {
                                    // Get.to(() => HistoryPage());
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          width: 2, color: orangeLightColor),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 15),
                                    child: Text(
                                      viewHistory,
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  )),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    "Summarization Mode",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  Container(
                                    child: DropdownButton<String>(
                                      // alignment: Alignment.center,
                                      borderRadius: BorderRadius.circular(30),
                                      value: _selectedMode,
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _selectedMode = newValue!;
                                        });
                                      },
                                      items: ["Extractive", "Abstractive"]
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                    decoration: BoxDecoration(
                                      // border: Border.all(
                                      //     width: 1, color: orangeLightColor),
                                      borderRadius: BorderRadius.circular(25),
                                      color: Colors.white,
                                    ),
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 15),
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 15),
                                    backgroundColor: orangeColor,
                                    foregroundColor: whiteColor,
                                  ),
                                  onPressed: () {
                                    BlocProvider.of<SummaryBloc>(context).add(
                                      SummarizeText(_controller.text,
                                          mode: _selectedMode),
                                    );
                                  },
                                  child: Text(
                                    summarize,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                BlocBuilder<SummaryBloc, SummaryState>(
                  builder: (context, state) {
                    if (state is SummaryLoading) {
                      return Column(
                        children: [
                          Text(
                            generatingSummary,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          CircularProgressIndicator(
                            color: Color.fromRGBO(223, 109, 20, 1),
                          ),
                        ],
                      );
                    } else if (state is SummaryLoaded) {
                      return Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    width: 4, color: orangeLightColor),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    summary,
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 8),
                                  Container(
                                    child: Text(state.summary,
                                        style: TextStyle(fontSize: 16)),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "Entered words: ${RegExp(r'\p{L}+', unicode: true).allMatches(_controller.text).length}",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        ", Entered sentences: ${_controller.text.split(RegExp(r'[.!?।॥]')).where((s) => s.trim().isNotEmpty).length}",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  (MediaQuery.of(context).size.width < 200)
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Summarized words: ${RegExp(r'\p{L}+', unicode: true).allMatches(state.summary).length}",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(
                                                width:
                                                    8), // Spacing between text elements
                                            Text(
                                              "Summarized sentences: ${state.summary.split(RegExp(r'[.!?।॥]')).where((s) => s.trim().isNotEmpty).length}",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        )
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Summarized words: ${RegExp(r'\p{L}+', unicode: true).allMatches(state.summary).length}",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(
                                                height:
                                                    4), // Spacing between text elements
                                            Text(
                                              "Summarized sentences: ${state.summary.split(RegExp(r'[.!?।॥]')).where((s) => s.trim().isNotEmpty).length}",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                ],
                              ),
                              padding: EdgeInsets.all(10),
                            ),
                            SizedBox(height: 10),
                            Container(
                              padding: EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          width: 2, color: orangeLightColor),
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.copy,
                                        color: darkFontGrey,
                                      ),
                                      onPressed: () {
                                        Clipboard.setData(
                                            ClipboardData(text: state.summary));
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(summaryCopieed)));
                                      },
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          width: 2, color: orangeLightColor),
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.share,
                                        color: darkFontGrey,
                                      ),
                                      onPressed: () {
                                        Share.share(state.summary);
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: 30,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          width: 2, color: orangeLightColor),
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.multitrack_audio,
                                        color: darkFontGrey,
                                      ),
                                      onPressed: () {
                                        toggleSpeech(state.summary);
                                      },
                                    ),
                                  ),
                                  GestureDetector(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            width: 2, color: orangeLightColor),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 15),
                                      child: Text(
                                        "Save",
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                    onTap: () async {
                                      if (_controller == null) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(
                                                    "Enter Text to summarize and save.")));
                                      } else {
                                        await _saveToFirestore(_controller.text,
                                            state.summary, _selectedMode);
                                      }
                                    },
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    } else if (state is SummaryError) {
                      return Text("❌ Error: ${state.error}",
                          style: TextStyle(color: Colors.red, fontSize: 24));
                    }
                    return Container();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
