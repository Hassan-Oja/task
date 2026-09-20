import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseManager {
  static Future<User?> createUser(String name, String email, String password,) async {
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user != null) {
        await user.updateDisplayName(name);
        await user.reload();
      }

      return FirebaseAuth.instance.currentUser;
    } catch (e) {
      print("An error happened while signing up");
      print(e);

      rethrow;
    }
  }
  static Future<void> sendVerificationEmail()async{

    await FirebaseAuth.instance.currentUser!.sendEmailVerification();

  }
  static Future<bool> checkIfUserVerified()async{

    final user = FirebaseAuth.instance.currentUser!;

    user.reload();

    return user.emailVerified;

  }
  static Future<void> saveUserIntoDatabase(String name, String email, User user,) async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .set({
        "name": name,
        "email": email,
        "uid": user.uid,
      });
    } catch (e) {
      print("An error happened while storing user into Firestore");
      print(e);
    }
  }
  static Future<String?> getUserName() async {
    final user = FirebaseAuth.instance.currentUser;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    final data = userDoc.data();

    return data?['name'] as String?;
  }
  static logout() async {
    await FirebaseAuth.instance.signOut();
  }
  static Future<void> loginUser(String email, String password)async{


    await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);


  }}

