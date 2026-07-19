import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';

void main() async {
  // 1. Ensure Flutter bindings are initialized before any async work
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 2. Check if Firebase is already initialized to prevent the duplicate-app error
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
          options: const FirebaseOptions(
              apiKey: "AIzaSyDo3flSCipedgBbtUdkBRiHO1oQGzvCcg0",
              appId: "1:451468119406:web:967481fed0bfd1e1cbc57f",
              messagingSenderId: "451468119406",
              projectId: "serveease-62edc"
          )
      );
      debugPrint("Firebase initialized successfully");
    } else {
      Firebase.app(); // Use existing instance
    }
  } catch (e) {
    // 3. Log the error but continue to runApp so the app doesn't stay "stuck"
    debugPrint("Firebase initialization error: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ServeEase',
      theme: ThemeData(
        // Optional: Setting a primary color to match your lightSeaGreen
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}