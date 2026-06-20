import 'pagesFolder/home_page.dart'; // Exemple si tu voulais importer cette page
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}


/*import 'package:flutter/material.dart';
// Importez votre service
import 'package:votre_projet/service/sudo_service.dart'; 

void main() {
  // Assure que le binding avec le moteur Flutter est prêt
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mon App Flask-Flutter',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
    );
  }
}*/