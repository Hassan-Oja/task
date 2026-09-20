import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uber/API/firebase_manager.dart';
import '../widgets/custom_text_field.dart';
import 'email_verification_screen.dart';
import 'login_screen.dart';

class SigninScreen extends StatelessWidget {
   SigninScreen({super.key});
  GlobalKey<FormState> _formKey = GlobalKey();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
   bool isWaitingForVerification = false;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(
                        Icons.route_outlined,
                        size: 150,
                        color: Colors.deepPurple,
                      ),
                      Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Please fill the form to continue",
                        style: TextStyle(fontSize: 20, color: Colors.grey),
                      ),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            CustomTextField(
                              hintText: 'Full Name',
                              prefixIcon: Icons.person,
                              controller: fullNameController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter your full name";
                                }
                                return null;
                              },
                            ),
                            CustomTextField(
                              hintText: 'Email',
                              prefixIcon: Icons.email,
                              controller: emailController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter your email";
                                } else if (!value.contains('@')) {
                                  return "Please enter a valid email";
                                }
                                return null;
                              },
                            ),
                            CustomTextField(
                              hintText: 'Password',
                              prefixIcon: Icons.lock,
                              controller: passwordController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter your password";
                                } else if (value.length < 6) {
                                  return "Password must be at least 6 characters";
                                }
                                return null;
                              },
                            ),
                            CustomTextField(
                              hintText: 'Confirm Password',
                              prefixIcon: Icons.lock,
                              controller: confirmPasswordController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter your password";
                                } else if (value.length < 6) {
                                  return "Password must be at least 6 characters";
                                } else if (value != passwordController.text) {
                                  return "Passwords do not match";
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final isValid = _formKey.currentState!.validate();
                            if (isValid) {
                              try {
                                final user = await FirebaseManager.createUser(
                                  fullNameController.text,
                                  emailController.text,
                                  passwordController.text,
                                );
                                await FirebaseManager.sendVerificationEmail();

                                // todo : go to home screen || Success Sign in
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EmailVerificationScreen(),
                                  ),
                                      (predicate) => false,
                                );
                              } on FirebaseAuthException catch (e) {
                                print(
                                  "<------------------------------${e.code}---------------------------->",
                                );
                                if (e.code == "email-already-in-use") {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Email already exists"),
                                    ),
                                  );
                                }
                              } catch (e) {
                                print(
                                  "error while signing up ========================> ${e.toString()}",
                                );
                              }
                            }
                          },
                          child: Text(
                            "Sign Up",
                            style: TextStyle(fontSize: 20),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: width * 0.1,
                              vertical: height * 0.01,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account?",
                            style: TextStyle(fontSize: 15),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginScreen(),
                                ),
                                    (predicate) => false,
                              );
                            },
                            child: Text(
                              "Log In",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),

    );
  }
}
