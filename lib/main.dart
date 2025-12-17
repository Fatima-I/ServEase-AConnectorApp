import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
        apiKey: "AIzaSyDo3flSCipedgBbtUdkBRiHO1oQGzvCcg0",
        appId: "1:451468119406:web:967481fed0bfd1e1cbc57f",
        messagingSenderId: "451468119406",
        projectId: "serveease-62edc"
    )
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My App',
      home: const HomeScreen(),
    );
  }
}
