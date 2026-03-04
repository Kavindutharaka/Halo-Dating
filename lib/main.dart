import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:halo/providers/auth_provider.dart';
import 'package:halo/providers/discover_provider.dart';
import 'package:halo/providers/match_provider.dart';
import 'package:halo/providers/chat_provider.dart';
import 'package:halo/screens/auth/phone_login_screen.dart';
import 'package:halo/screens/profile/profile_setup_screen.dart';
import 'package:halo/screens/home/main_navigation.dart';
import 'package:halo/utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // Firebase already initialized by google-services plugin — safe to ignore
  }
  runApp(const HaloApp());
}

class HaloApp extends StatelessWidget {
  const HaloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DiscoverProvider()),
        ChangeNotifierProvider(create: (_) => MatchProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        title: 'Halo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Not logged in
    if (!authProvider.isLoggedIn) {
      return const PhoneLoginScreen();
    }

    // Loading user data
    if (authProvider.userModel == null) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading...'),
            ],
          ),
        ),
      );
    }

    // Profile not complete
    if (!authProvider.isProfileComplete) {
      return const ProfileSetupScreen();
    }

    // Main app
    return const MainNavigation();
  }
}
