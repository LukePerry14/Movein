import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Auth {
  //Creating new instance of firebase auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> hasAccount(String email) async {
    final List methods = await _auth.fetchSignInMethodsForEmail(email);
    return methods.isNotEmpty;
  }

  Future<String> registerWithUserDetails(
      String email, String password, Map<String, dynamic> details) async {
    try {
      // This will create a new user in our firebase
      // print({email, password});
      // await _auth.createUserWithEmailAndPassword(
      //   email: email,
      //   password: password,
      // );

      print(details);

      FirebaseFirestore.instance.collection("Users").add(details).then(
          (DocumentReference doc) =>
              print('DocumentSnapshot added with ID: ${doc.id}'));
    } on FirebaseAuthException catch (e) {
      return e.code;
    } catch (e) {
      return 'Unknown error.';
    }
    return 'Signing in...';
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
