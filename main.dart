import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynewapp/todo_home_page.dart';
import 'firebase_options.dart';
import 'sign_in_page.dart';
import 'sign_up_page.dart';
import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.android,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SignInPage(),
      routes: {
        '/signup': (context) => SignUpPage(),
        '/home': (context) => HomePage(),
        '/todo': (context) => TodoHomePage(),
      },
    );
  }
}
