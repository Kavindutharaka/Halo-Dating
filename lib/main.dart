import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
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

  // Global Flutter error catcher
  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint('🔴🔴🔴 [FlutterError] ${details.exception}');
    debugPrint('🔴🔴🔴 [FlutterError] Stack:\n${details.stack}');
    FlutterError.dumpErrorToConsole(details);
  };

  // Global async/zone error catcher
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('🔴🔴🔴 [PlatformDispatcher] Unhandled error: $error');
    debugPrint('🔴🔴🔴 [PlatformDispatcher] Stack:\n$stack');
    return true;
  };

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

    debugPrint('🟣 [AuthWrapper] build: isLoggedIn=${authProvider.isLoggedIn}, userModel=${authProvider.userModel == null ? 'null' : 'set'}, error=${authProvider.error}, isProfileComplete=${authProvider.isProfileComplete}');

    // Not logged in → show phone login
    if (!authProvider.isLoggedIn) {
      debugPrint('🟣 [AuthWrapper] → PhoneLoginScreen (not logged in)');
      return const PhoneLoginScreen();
    }

    // Logged in but failed to load user data → sign out and retry
    if (authProvider.userModel == null && authProvider.error != null) {
      debugPrint('🔴 [AuthWrapper] → Firestore failed, signing out: error=${authProvider.error}');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        authProvider.signOut();
      });
      return const PhoneLoginScreen();
    }

    // Logged in but user data still loading
    if (authProvider.userModel == null) {
      debugPrint('🟣 [AuthWrapper] → Loading screen (waiting for Firestore)');
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

    // Profile not complete → show setup wizard
    if (!authProvider.isProfileComplete) {
      return const ProfileSetupScreen();
    }

    // All good → show main app
    return const MainNavigation();
  }
}
