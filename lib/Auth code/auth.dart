import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Auth {
  //Creating new instance of firebase auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> hasAccount(String email) async {
    final List methods = await _auth.fetchSignInMethodsForEmail(email);
    return methods.isNotEmpty;
  }

  String currentUser() {
    final User? user = _auth.currentUser;
    final uid = user?.uid.toString();
    return uid ?? "";
  }

  Future<String> registerWithUserDetails(
      String email, String password, Map<String, dynamic> details) async {
    try {
      // This will create a new user in our firebase
      print({email, password});
      var user = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print(user.user?.uid);

      FirebaseFirestore.instance
          .collection("Users")
          .doc(user.user?.uid)
          .set(details);

      return 'success';
    } on FirebaseAuthException catch (e) {
      return e.code;
    } catch (e) {
      return 'Unknown error.';
    }
  }

  Future<String> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      // This will Log in the existing user in our firebase
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return "success";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
      return e.code;
    } catch (e) {
      return "Unknown error.";
    }
  }
}
