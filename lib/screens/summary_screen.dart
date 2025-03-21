import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:share_plus/share_plus.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../bloc/summary/summary_bloc.dart';
import '../bloc/summary/summary_event.dart';
import '../bloc/summary/summary_state.dart';

class SummaryScreen extends StatefulWidget {
  @override
  _SummaryScreenState createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  final TextEditingController _controller = TextEditingController();
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  bool _isListening = false;
  bool _isPlaying = false;
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
        });
      });
    }
  }

  void _stopListening() {
    setState(() => _isListening = false);
    _speech.stop();
  }

  void _toggleSpeech(String text) async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color.fromRGBO(58, 125, 68, 1),
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Sumaize',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 28,
                color: Color.fromRGBO(248, 245, 233, 1),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                // padding: EdgeInsets.all(5),
                backgroundColor: const Color.fromRGBO(223, 109, 20, 1),
                foregroundColor: Color.fromRGBO(
                    248, 245, 233, 1), // Optional: Set text color
              ),
              onPressed: () {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text("History Opened!")));
              },
              child: Text("History"),
            ),
          ],
        ),
        // centerTitle: true,
        backgroundColor: Color.fromRGBO(58, 125, 68, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    border: Border.all(
                        width: 4, color: Color.fromRGBO(223, 109, 20, 0.4)),
                    borderRadius: BorderRadius.circular(10),
                    color: Color.fromRGBO(248, 245, 233, 1)),
                child: Column(
                  children: [
                    TextField(
                      maxLines: 10,
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Enter text to summarize',
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        // color: ,
                        color: Color.fromRGBO(157, 192, 139, 1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(
                              _isListening ? Icons.mic_off : Icons.mic,
                              color: Color.fromRGBO(248, 245, 233, 1),
                            ),
                            onPressed:
                                _isListening ? _stopListening : _startListening,
                          ),
                          // ElevatedButton.icon(
                          //   style: ElevatedButton.styleFrom(
                          //     backgroundColor: Color.fromRGBO(157, 192, 139, 1),
                          //     foregroundColor: Colors.white,
                          //   ),
                          //   icon: Icon(Icons.file_present),
                          //   label: Text("Summarize File"),
                          //   onPressed: () {
                          //     Navigator.push(
                          //       context,
                          //       MaterialPageRoute(
                          //           builder: (context) =>
                          //               FileSummarizerScreen()),
                          //     );
                          //   },
                          // ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              // padding: EdgeInsets.all(5),
                              backgroundColor:
                                  const Color.fromRGBO(58, 125, 68, 1),
                              foregroundColor: Color.fromRGBO(
                                  248, 245, 233, 1), // Optional: Set text color
                            ),
                            onPressed: _pickFile,
                            child: Text("Pick PDF/Image File"),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              // padding: EdgeInsets.all(5),
                              backgroundColor:
                                  const Color.fromRGBO(223, 109, 20, 1),
                              foregroundColor: Color.fromRGBO(
                                  248, 245, 233, 1), // Optional: Set text color
                            ),
                            onPressed: () {
                              BlocProvider.of<SummaryBloc>(context)
                                  .add(SummarizeText(_controller.text));
                            },
                            child: Text('Summarize'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              BlocBuilder<SummaryBloc, SummaryState>(
                builder: (context, state) {
                  if (state is SummaryLoading) {
                    return Column(
                      children: [
                        Text(
                          "Generating Summary",
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
                    return Card(
                      color: Color.fromRGBO(248, 245, 233, 1),
                      elevation: 4,
                      // margin: EdgeInsets.all(8),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            border: Border.all(
                                width: 4,
                                color: Color.fromRGBO(223, 109, 20, 0.4)),
                            borderRadius: BorderRadius.circular(10),
                            color: Color.fromRGBO(248, 245, 233, 1)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Summary:",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Container(
                              // height: ,
                              child: Text(state.summary,
                                  style: TextStyle(fontSize: 16)),
                            ),
                            SizedBox(height: 8),
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                // color: ,
                                color: Color.fromRGBO(157, 192, 139, 1),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.copy,
                                      color: Color.fromRGBO(248, 245, 233, 1),
                                    ),
                                    onPressed: () {
                                      Clipboard.setData(
                                          ClipboardData(text: state.summary));
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content:
                                                  Text("Summary copied!")));
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.share,
                                      color: Color.fromRGBO(248, 245, 233, 1),
                                    ),
                                    onPressed: () {
                                      Share.share(state.summary);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.multitrack_audio,
                                      color: Color.fromRGBO(248, 245, 233, 1),
                                    ),
                                    onPressed: () {
                                      _toggleSpeech(state.summary);
                                    },
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
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
    );
  }
}
