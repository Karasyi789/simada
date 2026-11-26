import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'screens/auth/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SimadaApp());
}

class SimadaApp extends StatelessWidget {
  const SimadaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}
