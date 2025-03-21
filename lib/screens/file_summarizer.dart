import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../bloc/summary/summary_bloc.dart';
import '../bloc/summary/summary_event.dart';
import '../bloc/summary/summary_state.dart';

class FileSummarizerScreen extends StatefulWidget {
  @override
  _FileSummarizerScreenState createState() => _FileSummarizerScreenState();
}

class _FileSummarizerScreenState extends State<FileSummarizerScreen> {
  late FlutterTts _flutterTts;

  String _extractedText = "";
  bool _isSummarizing = false;
  bool _isPlaying = false;

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
      setState(() => _extractedText = text);
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
    setState(() => _extractedText = recognizedText.text);
    textDetector.close();
  }

  // void _stopSummarization() {
  //   setState(() => _isSummarizing = false);
  //   BlocProvider.of<SummaryBloc>(context).add(CancelSummarization());
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(58, 125, 68, 1),
      appBar: AppBar(
        title: Text(
          "File Summarizer",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
        ),
        backgroundColor: Color.fromRGBO(58, 125, 68, 1),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
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
                    // SizedBox(height: 16),
                    _extractedText.isNotEmpty
                        ? Container(
                            padding: EdgeInsets.all(10),
                            height: 400,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Color.fromRGBO(248, 245, 233, 1),
                            ),
                            child: SingleChildScrollView(
                              child: TextField(
                                controller:
                                    TextEditingController(text: _extractedText),
                                maxLines: null, // Allows multiple lines
                                decoration: InputDecoration(
                                  // border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Color.fromRGBO(248, 245, 233, 1),
                                ),
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black),
                                onChanged: (text) {
                                  setState(() {
                                    _extractedText = text;
                                  });
                                },
                              ),
                            ),
                          )
                        : Text("No text extracted yet."),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: _pickFile,
                          child: Text("Pick PDF/Image File"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() => _isSummarizing = true);
                            BlocProvider.of<SummaryBloc>(context)
                                .add(SummarizeText(_extractedText));
                          },
                          child: Text("Summarize"),
                        ),
                      ],
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
                        Text("Generating Summary"),
                        SizedBox(height: 10),
                        CircularProgressIndicator(
                            color: Color.fromRGBO(223, 109, 20, 1)),
                      ],
                    );
                  } else if (state is SummaryLoaded) {
                    return Card(
                      color: Color.fromRGBO(248, 245, 233, 1),
                      elevation: 4,
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
                            Text(state.summary, style: TextStyle(fontSize: 16)),
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

class CancelSummarization extends SummaryEvent {}
