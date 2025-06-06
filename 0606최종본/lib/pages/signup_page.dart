import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:project_eb_flutter/pages/settings_page.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
final databaseRef = FirebaseDatabase.instance.ref();

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> signupUser() async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      await databaseRef.child("users").child(userCredential.user!.uid).set({
        "email": userCredential.user!.email,
        "timestamp": DateTime.now().toString(),
      });

      Navigator.pushNamed(context, "/");  // 회원가입 후 홈 이동
    } catch (e) {
      print("회원가입 실패: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsPage()),
          );
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset('assets/images/signup_background.jpg', fit: BoxFit.cover),
            ),

            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.black.withOpacity(0.2)),
              ),
            ),

            Center(
              child: GestureDetector(
                onTap: () {},  // 🔹 내부 UI 클릭 시 뒤로 가지 않도록 설정
                child: Container(
                  padding: const EdgeInsets.all(24),
                  width: 350,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white.withOpacity(0.25),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "회원가입",
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 20),

                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(labelText: "E-Mail"),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: "Password"),
                      ),
                      const SizedBox(height: 20),

                      ElevatedButton(
                        onPressed: signupUser,
                        child: const Text("가입하기"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        child: const Text(
                          "이미 계정이 있으신가요? 로그인",
                          style: TextStyle(
                            color: Colors.white70,

                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
