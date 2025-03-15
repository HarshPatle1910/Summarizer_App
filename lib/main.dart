import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smart_summariser/bloc/authentications/auth_bloc.dart';
import 'package:smart_summariser/screens/home_screens.dart';

import 'bloc/summary_bloc.dart';
import 'services/api_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final storage = FlutterSecureStorage();

  // ✅ Store API Key (ONLY RUN ONCE)
  await storage.write(
      key: "GEMINI_API_KEY", value: "AIzaSyCAhMmmUwtfHvksE9qpt9O2SwhoaMiFwmU");

  // ✅ Retrieve & Print API Key
  String? apiKey = await storage.read(key: "GEMINI_API_KEY");
  print("🔍 Stored API Key: $apiKey");

  final apiService = ApiService();
  runApp(MyApp(apiService: apiService));
}

class MyApp extends StatelessWidget {
  final ApiService apiService;

  MyApp({required this.apiService});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(),
        ),
        BlocProvider<SummaryBloc>(
          create: (context) => SummaryBloc(apiService: apiService),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Smart Summarizer',
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
        ),
        // home: LoginPage(),
        home: HomeScreen(),
      ),
    );
  }
}
