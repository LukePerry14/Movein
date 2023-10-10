import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

// For Sendgrid mailing
import 'package:sendgrid_mailer/sendgrid_mailer.dart';

void sendEmail(to) async {
  const String API_KEY =
      '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';
  const String TEMPLATE_ID = 'd-3d2e323131ea498d9e5e58348406a380';
  const String SGEmail = 'feedback@move1n.co.uk';

  final url = Uri.parse('https://api.sendgrid.com/v3/mail/send');
  final headers = {
    'Authorization': 'Bearer $API_KEY',
    'Content-Type': 'application/json'
  };

  final body = {
    "personalizations": [
      {
        'to': [
          {'email': to}
        ]
      }
    ],
    "from": {'email': SGEmail},
    "template_id": TEMPLATE_ID
  };

  final response =
      await http.post(url, headers: headers, body: json.encode(body));

  if (response.statusCode != 202) {
    print('Email failed - ${response.body}');
  } else {
    print('email send');
  }
}

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

  addAccessToken(String accessToken, String userId) {
    FirebaseFirestore.instance
        .collection("Users")
        .doc(userId)
        .update({'AccessToken': accessToken}).then((_) {
      print('Success');
    }).catchError((error) {
      print('failed');
    });
  }

  Future<String> registerWithUserDetails(
      String email, String password, Map<String, dynamic> details) async {
    try {
      // This will create a new user in our firebase
      var user = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

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
      // Removes whitespace from string in case it was entered
      email.replaceAll(' ', '');

      // This will Log in the existing user in our firebase
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = FirebaseAuth.instance.currentUser;

      // if (user != null && !user.emailVerified) {
      //   await user.sendEmailVerification();
      //   return "email verification";
      // }

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
