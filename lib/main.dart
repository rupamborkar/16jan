import 'package:flutter/material.dart';
import 'package:margo/constants/material.dart';
import 'package:margo/screens/Login_Screen/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Margo',
      theme: ThemeData(
          fontFamily: 'Poppins',
          scaffoldBackgroundColor: Colors.white,
          appBarTheme:
              const AppBarTheme(backgroundColor: AppColors.backgroundColor)),
      home: LoginScreen(),
    );
  }
}
