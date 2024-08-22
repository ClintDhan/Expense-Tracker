import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_project/firebase_options.dart';
import 'package:flutter_application_project/home_page.dart';

// Define your custom colors
const Color purple = Color(0xff602e9e);
const Color babypowder = Color(0xfffefefa);
const Color darkBackground = Color(0xff121212);
const Color darkCard = Color(0xff1E1E1E);
const Color darkTextField = Color(0xff2C2C2C);
const Color lightText = Color(0xffE0E0E0);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: ThemeData(
        fontFamily: "Inter",
        colorScheme: ColorScheme.fromSeed(
          seedColor: darkBackground,
          background: darkBackground, // Use dark background color
          primary: purple, // Use purple as primary color
          primaryContainer: darkBackground, // Use dark card color
          secondary: darkBackground, // Use babypowder as secondary color
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
