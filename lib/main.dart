import 'package:flutter/material.dart';
import 'core/app_colors.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const NovelReaderApp());
}

class NovelReaderApp extends StatelessWidget {
  const NovelReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Novelina',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: AppColors.primaryBlue,
        scaffoldBackgroundColor: AppColors.lightBlue,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
