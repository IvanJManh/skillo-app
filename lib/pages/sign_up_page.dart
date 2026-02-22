import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:newskilloapp/pages/sign_in_page.dart';
import 'package:newskilloapp/pages/home_page.dart';
import 'package:newskilloapp/pages/skill_notifier.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final SkillNotifier _skillNotifier = SkillNotifier();

  String? _errorText;
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _checkPasswordMatch() {
    final pass = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (pass.isEmpty || confirm.isEmpty) {
      setState(() => _errorText = null);
      return;
    }

    if (pass != confirm) {
      setState(() => _errorText = "Passwords do not match");
    } else {
      setState(() => _errorText = null);
    }
  }

  bool _validate() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final pass = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || pass.isEmpty || confirm.isEmpty) {
      setState(() => _errorText = "All fields are required");
      return false;
    }

    if (pass.length < 6) {
      setState(() => _errorText = "Password must be at least 6 characters");
      return false;
    }

    if (pass != confirm) {
      setState(() => _errorText = "Passwords do not match");
      return false;
    }

    setState(() => _errorText = null);
    return true;
  }

  Future<void> _signUp() async {
    if (!_validate()) return;

    setState(() => _loading = true);

    try {
      // 1) Create user in Firebase Auth
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = cred.user;
      if (user == null) {
        throw FirebaseAuthException(code: "user-null");
      }

      // 2) Save display name to Auth profile
      await user.updateDisplayName(_nameController.text.trim());
      await user.reload();

      final refreshedUser = FirebaseAuth.instance.currentUser;
      final uid = refreshedUser?.uid;

      if (uid == null) {
        throw FirebaseAuthException(code: "missing-uid");
      }

      // 3) Save user profile to Firestore (users/{uid})
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': _nameController.text.trim(),
        'email': refreshedUser?.email ?? _emailController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 4) Go Home
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomePage(
            skillNotifier: _skillNotifier,
            userName: refreshedUser?.displayName ?? _nameController.text.trim(),
            userEmail: refreshedUser?.email ?? _emailController.text.trim(),
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      // Common: email-already-in-use, weak-password, invalid-email
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sign up failed: ${e.code}")),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sign up failed: $e")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 150,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('lib/images/background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: const Padding(
            padding: EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'New to this app?',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 0),
                Text(
                  'Sign up now and learn a new skill every day.',
                  style: TextStyle(color: Colors.white, fontSize: 13.5),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Enter your name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Enter your email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                obscureText: true,
                controller: _passwordController,
                onChanged: (_) => _checkPasswordMatch(),
                decoration: InputDecoration(
                  labelText: 'Enter your password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                obscureText: true,
                controller: _confirmPasswordController,
                onChanged: (_) => _checkPasswordMatch(),
                decoration: InputDecoration(
                  labelText: 'Confirm your password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              if (_errorText != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    _errorText!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              const SizedBox(height: 20),

              SizedBox(
                height: 45,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_errorText != null || _loading) ? null : _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 71, 172, 200),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Sign up',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                ),
              ),

              const SizedBox(height: 90),

              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Do have an account? "),
                    GestureDetector(
                      onTap: _loading
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SignInPage(),
                                ),
                              );
                            },
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 130, 167),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
