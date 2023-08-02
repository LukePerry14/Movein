import 'package:firebase_auth/firebase_auth.dart';

class Auth {
  //Creating new instance of firebase auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> hasAccount(String email) async {
    final List methods = await _auth.fetchSignInMethodsForEmail(email);
    return methods.isNotEmpty;
  }

  Future<String> registerWithUserDetails(
      String email, String password, String firstName, String lastName) async {
    try {
      // This will create a new user in our firebase
      // print({email, password});
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print({firstName, lastName, 'need storing'});
    } on FirebaseAuthException catch (e) {
      return e.code;
    } catch (e) {
      return 'Unknown error.';
    }
    return 'Signing in...';
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      // This will Log in the existing user in our firebase
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    } catch (e) {
      print(e);
    }
  }
}
