import 'package:finalapp/database/filter_provider.dart';
import 'package:finalapp/database/search_provider.dart';
import 'package:finalapp/database/student_provider.dart';
import 'package:finalapp/firebase_options.dart';
import 'package:finalapp/screens/listScreen.dart';
import 'package:finalapp/screens/registor.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StudentProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => FilterProvider()),
        // ChangeNotifierProvider(create: (_) => PhoneAuthProvider())
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Auth Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snap) {
            if (snap.data != null || snap.hasData) {
              return StudentListScreen();
            }
            return RegistrationPage();
          }), // Set the LoginPage as the home page
      debugShowCheckedModeBanner: false,
    );
  }
}
