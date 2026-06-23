import 'pagesFolder/home_page.dart'; // Exemple si tu voulais importer cette page
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pagesFolder/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SudoAuthService.init();
  runApp(const MyApp());
}
