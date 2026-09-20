import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uber/API/firebase_manager.dart';
import 'home_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

late Timer timer;



class _EmailVerificationScreenState extends State<EmailVerificationScreen> {

  @override
  void initState()  {

    bool isUserVerified;
    timer = Timer.periodic(Duration(seconds: 3), (_) async {
      isUserVerified = await FirebaseManager.checkIfUserVerified();
      if (isUserVerified) {
        await FirebaseManager.saveUserIntoDatabase(
          FirebaseAuth.instance.currentUser!.displayName!,
          FirebaseAuth.instance.currentUser!.email!,
          FirebaseAuth.instance.currentUser!,
        );
        timer.cancel();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
              (routes) => false,
        );
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              const Text(
                "Verification email sent!",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Please check your email and verify your account.",
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
