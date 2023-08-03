import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:movein/Pages/OnBoarding.dart';
import 'package:movein/Pages/Scroller.dart';
import 'package:movein/Themes/lMode.dart';
import 'package:movein/Pages/Houses.dart';
import 'package:movein/Pages/Messages.dart';
import 'package:movein/Pages/Profile.dart';
import 'package:movein/Pages/Settings.dart';
import 'package:movein/Pages/profileInformation.dart';
import 'package:movein/Pages/GroupOptions.dart';
import 'package:movein/Pages/Friends.dart';
import 'package:movein/Pages/ScrollRefresh.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Auth code/auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // await Settings.init(cacheProvider: CustomCacheProvider());
  // Run the app
  runApp(const App());
}

class App extends StatelessWidget {
  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);
  
  const App({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,

      builder: (context, currentMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: LAppTheme.lightTheme,
          darkTheme: LAppTheme.darkTheme,
          themeMode: currentMode,
          // initialRoute: '/Auth',
          initialRoute:
              FirebaseAuth.instance.currentUser == null ? '/Auth' : '/Scroller',
          routes: {
            '/Auth': (context) => const AuthScreen(),
            '/Scroller': (context) => const Scroller(),
            '/ScrollRefresh': (context) => const RanOut(),
            '/Messages': (context) => const Messages(),
            '/Profile': (context) => const Profile(),
            '/Settings': (context) => const Settings(),
            '/profileInformation': (context) => const profileInformation(),
            '/Friends': (context) => const Friends(),
            '/Houses': (context) => const Houses(),
            '/GroupOptions': (context) => const GroupOptions(),
            '/OnBoarding' : (context) => const OnBoardingPage(),
          },
        );
      }
    );
    }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  String state = "email-unknown";

  //Use this form key to validate user's input
  final _formKey = GlobalKey<FormState>();

  //Use this to store user inputs
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  back() {
    setState(() {
      state = "email-unknown";
    });
  }

  handleSubmit() async {
    final email = _emailController.value.text;
    if (state == "email-unknown") {
      if (await Auth().hasAccount(email)) {
        state = "email-known-has-account";
      } else {
        state = "new-email-needs-account";
      }
      setState(() {
        state;
      });
      return;
    }

    if (state == "email-known-has-account") {
      final password = _passwordController.value.text;
      Auth().signInWithEmailAndPassword(email, password);
      Navigator.pushNamed(context, '/Scroller'); // THIS SHOULD BE CONDITIONAL
      return;
    }

    if (state == 'new-email-needs-account') {
      if (_formKey.currentState!.validate()) {
        final password = _passwordController.value.text;
        final firstName = _firstNameController.value.text;
        final lastName = _lastNameController.value.text;

        Auth().registerWithUserDetails(email, password, firstName, lastName);
        Navigator.pushNamed(context, '/OnBoarding'); // THIS SHOULD BE CONDITIONAL
      }
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auth Screen'),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Form(
                //Add form to key to the Form Widget
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: back,
                      child: TextFormField(
                        enabled: state == 'email-unknown',
                        //Assign controller
                        controller: _emailController,
                        //Use this function to validate user input
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          hintText: 'Email',
                        ),
                      ),
                    ),
                    if (state != 'email-unknown') ...[
                      TextFormField(
                        controller: _passwordController,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value.length < 8) {
                            return 'Password must be greater than eight characters.';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          hintText: 'Password',
                        ),
                      )
                    ],
                    if (state == 'new-email-needs-account') ...[
                      TextFormField(
                          controller: _firstNameController,
                          decoration: const InputDecoration(
                            hintText: 'First Name',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'You must enter a first name.';
                            }
                            return null;
                          }),
                      TextFormField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(
                          hintText: 'Last Name',
                        ),
                      )
                    ],
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      //Assigned onPressed to submit
                      onPressed: handleSubmit,
                      //Conditionally show the button label
                      child: Text(state == 'email-unknown'
                          ? 'Next'
                          : (state == 'new-email-needs-account'
                              ? 'Sign up'
                              : 'Login')),
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
