import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:newskilloapp/pages/home_page.dart';
import 'package:newskilloapp/pages/skill_notifier.dart';



class AuthTestPage extends StatefulWidget {
  const AuthTestPage({super.key});

  @override
  State<AuthTestPage> createState() => _AuthTestPageState();
}

class _AuthTestPageState extends State<AuthTestPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String msg = '';

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> signUp() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      setState(() => msg = '✅ Sign up success');
    } on FirebaseAuthException catch (e) {
      setState(() => msg = '❌ Sign up failed: ${e.code}');
    }
  }

  Future<void> login() async {
  try {
    final user = FirebaseAuth.instance.currentUser;

if (!mounted) return;

Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (_) => HomePage(
      skillNotifier: SkillNotifier(),
      userName: user?.displayName ?? "User",
      userEmail: user?.email ?? "",
    ),
  ),
);

  } on FirebaseAuthException catch (e) {
    setState(() => msg = '❌ Login failed: ${e.code}');
  }
}

  Future<void> resetPassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );
      setState(() => msg = '📩 Password reset email sent');
    } on FirebaseAuthException catch (e) {
      setState(() => msg = '❌ Reset failed: ${e.code}');
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    setState(() => msg = '✅ Logged out');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Auth Test')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 18),
            ElevatedButton(onPressed: signUp, child: const Text('Sign Up')),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: login, child: const Text('Login')),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: resetPassword, child: const Text('Reset Password')),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: logout, child: const Text('Logout')),
            const SizedBox(height: 16),
            Text(msg),
          ],
        ),
      ),
    );
  }
}
