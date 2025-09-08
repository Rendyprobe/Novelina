import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'routes/routes.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/signup_screen.dart';

void main() {
  runApp(const QuranApp());
}

class QuranApp extends StatelessWidget {
  const QuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Qur'an App",
      theme: buildAppTheme(),
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.home: (c) => const LoginScreen(), // sementara
        AppRoutes.login: (c) => const LoginScreen(),
        AppRoutes.signup: (c) => const SignUpScreen(),
      },
    );
  }
}