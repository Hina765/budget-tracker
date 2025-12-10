import 'package:expense_tracker/screens/splash_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BudgetTracker',
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xffF5F7FA),
        appBarTheme: AppBarTheme(backgroundColor: Color(0xffF5F7FA)),
      ),
      home: SplashScreen()
    );
  }
}


