import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'login_page.dart'; // Import the login page file

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures Flutter is initialized
  try {
    await Firebase.initializeApp();
    runApp(const TournamentManagementApp());
  } catch (e) {
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(child: Text('Failed to initialize Firebase: $e')),
      ),
    ));
  }
}

class TournamentManagementApp extends StatelessWidget {
  const TournamentManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tournament Management App',
      theme: ThemeData(
        primarySwatch: Colors.green, // Customize primary color
      ),
      home: const LoginPage(), // Set LoginPage as the home page
      debugShowCheckedModeBanner: false,
    );
  }
}
