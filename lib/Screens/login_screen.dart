import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uber/API/firebase_manager.dart';
import 'package:uber/Screens/signin_screen.dart';
import '../widgets/custom_text_field.dart';
import 'email_verification_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatelessWidget {
 LoginScreen({super.key});
  GlobalKey<FormState> _formKey = GlobalKey();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
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
                "Welcome Back",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
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
                      hintText: 'Email',
                      prefixIcon: Icons.email,
                      controller: emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your email";
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your password";
                        } else if (value.length < 6) {
                          return "Password must be at least 6 characters";
                        }
                        return null;
                      },
                      hintText: 'Password',
                      prefixIcon: Icons.lock,
                      controller: passwordController,
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
                      try{
                        await FirebaseManager.loginUser(
                            emailController.text,
                            passwordController.text
                        );

                        if(FirebaseAuth.instance.currentUser!.emailVerified){

                          Navigator.pushAndRemoveUntil(context,
                              MaterialPageRoute(builder:(context) => HomeScreen(),),
                                  (route) => false
                          );

                        }else{

                          Navigator.pushAndRemoveUntil(context,
                              MaterialPageRoute(builder:(context) => EmailVerificationScreen(),),
                                  (route) => false
                          );
                        }
                      } on FirebaseAuthException catch (e) {
                        print("--------------------${e.code}--------------");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              e.code,
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        );
                      } catch (e) {
                        print(
                          "==========> error while signing up ${e.toString()}",
                        );
                      }
                    }
                  },
                  child: Text("Log In", style: TextStyle(fontSize: 20)),
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
                    "Don't have an account?",
                    style: TextStyle(fontSize: 15),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => SigninScreen()),
                            (predicate) => false,
                      );
                    },
                    child: Text(
                      "Sign In",
                      style: TextStyle(fontSize: 15, color: Colors.deepPurple),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
