import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'utils/storage.dart';
import 'screens/onboarding_screen.dart';
import 'screens/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.bg,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  final onboarded = await Storage.isOnboarded();
  runApp(PowerCornerApp(onboarded: onboarded));
}

class PowerCornerApp extends StatelessWidget {
  final bool onboarded;
  const PowerCornerApp({super.key, required this.onboarded});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PowerCorner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme(),
      home: onboarded ? const MainShell() : const OnboardingScreen(),
    );
  }
}
