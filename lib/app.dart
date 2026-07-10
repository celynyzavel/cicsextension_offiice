import 'package:flutter/material.dart';
import 'theme/app_colors.dart';
import 'screens/login_page.dart';

class CicsExtensionApp extends StatelessWidget {
  const CicsExtensionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CICS Extension Projects and Technology Transfer',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: kBackground,
        colorScheme: ColorScheme.dark(
          primary: kPrimary,
          surface: kCard,
          secondary: kPrimary,
        ),
      ),
      home: const LoginPage(),
    );
  }
}
