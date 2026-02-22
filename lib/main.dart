import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'package:newskilloapp/pages/home_page.dart';
import 'package:newskilloapp/pages/sign_in_page.dart';
import 'package:newskilloapp/pages/skill_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
    );
  }
}

/// Shows YOUR pages. Firebase does not show any UI here.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // while checking login
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        // Not logged in -> YOUR custom sign in page
        if (user == null) {
          return const SignInPage();
        }

        // Logged in -> Home
        return HomePage(
          skillNotifier: SkillNotifier(),
          userName: user.displayName ?? "User",
          userEmail: user.email ?? "",
        );
      },
    );
  }
}