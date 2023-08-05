import 'dart:async';
import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get/get_navigation/src/root/get_material_app.dart';
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
import 'package:movein/Translations.dart';
import 'package:movein/UserPreferences.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './auth.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await UserPreferences.init();
  // await Settings.init(cacheProvider: CustomCacheProvider());
  // Run the app
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // return Placeholder();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: LAppTheme.lightTheme,
      darkTheme: LAppTheme.darkTheme,
      themeMode: ThemeMode.light,
      // initialRoute: '/Auth',
      initialRoute:
          FirebaseAuth.instance.currentUser == null ? '/Login' : '/Scroller',
      routes: {
        '/Login': (context) => const LoginScreen(),
        '/Signup': (context) => const SignupScreen(),
        '/Scroller': (context) => const Scroller(),
        '/ScrollRefresh': (context) => const RanOut(),
        '/Messages': (context) => const Messages(),
        '/Profile': (context) => const Profile(),
        '/Settings': (context) => const Settings(),
        '/profileInformation': (context) => const profileInformation(),
        '/Friends': (context) => const Friends(),
        '/Houses': (context) => const Houses(),
        '/GroupOptions': (context) => const GroupOptions(),
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  String error_message = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            children: [
              FormBuilderTextField(
                name: 'email',
                decoration: const InputDecoration(labelText: 'Email'),
                // enabled: false,

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },

                // validator: FormBuilderValidators.compose([
                // FormBuilderValidators.required(),
                // FormBuilderValidators.email(),
                // ]),
              ),
              const SizedBox(height: 10),
              FormBuilderTextField(
                name: 'password',
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              Text(error_message),
              const SizedBox(height: 5),
              MaterialButton(
                color: Theme.of(context).colorScheme.primary,
                onPressed: () async {
                  // Validate and save the form values

                  if (_formKey.currentState?.saveAndValidate() == false) {
                    return;
                  }

                  String response = await Auth().signInWithEmailAndPassword(
                      _formKey.currentState?.fields['email']?.value,
                      _formKey.currentState?.fields['password']?.value);

                  if (response == 'success') {
                    Navigator.pushNamed(context, '/Scroller');
                    return;
                  } else {
                    setState(() {
                      var errors = {
                        'invalid-email': 'Enter a valid email',
                        'wrong-password': 'Incorrect password'
                      };
                      error_message = errors[response] ?? response;
                    });
                  }
                  return;
                },
                child: const Text('Login'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () async {
                  Navigator.pushNamed(context, '/Signup');
                },
                child: const Text('Want to sign up instead?'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  String error_message = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signup'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              children: [
                FormBuilderTextField(
                  name: 'email',
                  decoration: const InputDecoration(labelText: 'Email'),
                  // enabled: false,

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                FormBuilderTextField(
                  name: 'password',
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                FormBuilderTextField(
                  name: 'bio',
                  decoration: const InputDecoration(labelText: 'Bio'),
                  // enabled: false,

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a bio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                FormBuilderDateTimePicker(
                  inputType: InputType.date,
                  name: "dob",
                  decoration: const InputDecoration(labelText: 'Date of Birth'),
                ),
                const SizedBox(height: 10),
                FormBuilderTextField(
                  name: 'forename',
                  decoration: const InputDecoration(labelText: 'First Name'),
                  // enabled: false,

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                FormBuilderTextField(
                  name: 'surname',
                  decoration: const InputDecoration(labelText: 'Last Name'),
                  // enabled: false,

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                FormBuilderSlider(
                  name: 'cleanliness',
                  initialValue: 2,
                  min: 0,
                  max: 5,
                  divisions: 5,
                  decoration: const InputDecoration(labelText: 'Cleanliness'),
                ),
                FormBuilderSlider(
                  name: 'noisiness',
                  initialValue: 2,
                  min: 0,
                  max: 5,
                  divisions: 5,
                  decoration: const InputDecoration(labelText: 'Noisiness'),
                ),
                FormBuilderSlider(
                  name: 'nightlife',
                  initialValue: 2,
                  min: 0,
                  max: 5,
                  divisions: 5,
                  decoration: const InputDecoration(labelText: 'Nightlife'),
                ),
                FormBuilderDateTimePicker(
                  name: 'bedtime',
                  inputType: InputType.time,
                  decoration: const InputDecoration(labelText: 'Bedtime'),
                ),
                FormBuilderTextField(
                  name: 'subject',
                  decoration:
                      const InputDecoration(labelText: 'Subject Studied'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                FormBuilderTextField(
                  name: 'University',
                  decoration:
                      const InputDecoration(labelText: 'University Attended'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                FormBuilderSlider(
                  name: 'yearofstudy',
                  initialValue: 1,
                  min: 1,
                  max: 7,
                  divisions: 6,
                  decoration: const InputDecoration(labelText: 'Year of Study'),
                ),
                Text(error_message),
                const SizedBox(height: 5),
                MaterialButton(
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: () async {
                    // Validate and save the form values

                    if (_formKey.currentState?.saveAndValidate() == false) {
                      return;
                    }

                    // debugPrint(_formKey.currentState?.value.toString());

                    String response = await Auth().registerWithUserDetails(
                        _formKey.currentState?.fields['email']?.value,
                        _formKey.currentState?.fields['password']?.value,
                        _formKey.currentState?.value ?? {});

                    // if (response == 'success') {
                    //   Navigator.pushNamed(context, '/Scroller');
                    //   return;
                    // } else {
                    //   setState(() {
                    //     var errors = {
                    //       'invalid-email': 'Enter a valid email',
                    //       'wrong-password': 'Incorrect password'
                    //     };
                    //     error_message = errors[response] ?? response;
                    //   });
                    // }
                    // return;
                  },
                  child: const Text('Signup'),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () async {
                    Navigator.pushNamed(context, '/Login');
                  },
                  child: const Text('Want to log in instead?'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// class AuthScreen extends StatefulWidget {
//   const AuthScreen({super.key});

//   @override
//   State<AuthScreen> createState() => _AuthScreenState();
// }

// class _AuthScreenState extends State<AuthScreen> {
//   String state = "email-unknown";

//   //Use this form key to validate user's input
//   final _formKey = GlobalKey<FormState>();

//   //Use this to store user inputs
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();

//   final TextEditingController _firstNameController = TextEditingController();
//   final TextEditingController _lastNameController = TextEditingController();

//   back() {
//     setState(() {
//       state = "email-unknown";
//     });
//   }

//   handleSubmit() async {
//     final email = _emailController.value.text;
//     if (state == "email-unknown") {
//       if (await Auth().hasAccount(email)) {
//         state = "email-known-has-account";
//       } else {
//         state = "new-email-needs-account";
//       }
//       setState(() {
//         state;
//       });
//       return;
//     }

//     if (state == "email-known-has-account") {
//       final password = _passwordController.value.text;
//       Auth().signInWithEmailAndPassword(email, password);
//       Navigator.pushNamed(context, '/Scroller'); // THIS SHOULD BE CONDITIONAL
//       return;
//     }

//     if (state == 'new-email-needs-account') {
//       if (_formKey.currentState!.validate()) {
//         final password = _passwordController.value.text;
//         final firstName = _firstNameController.value.text;
//         final lastName = _lastNameController.value.text;

//         Auth().registerWithUserDetails(email, password, firstName, lastName);
//         Navigator.pushNamed(context, '/Scroller'); // THIS SHOULD BE CONDITIONAL
//       }
//     }
//     return;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Auth Screen'),
//       ),
//       body: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               Form(
//                 //Add form to key to the Form Widget
//                 key: _formKey,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     GestureDetector(
//                       behavior: HitTestBehavior.opaque,
//                       onTap: back,
//                       child: TextFormField(
//                         enabled: state == 'email-unknown',
//                         //Assign controller
//                         controller: _emailController,
//                         //Use this function to validate user input
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter your email';
//                           }
//                           return null;
//                         },
//                         decoration: const InputDecoration(
//                           hintText: 'Email',
//                         ),
//                       ),
//                     ),
//                     if (state != 'email-unknown') ...[
//                       TextFormField(
//                         controller: _passwordController,
//                         validator: (value) {
//                           if (value == null ||
//                               value.isEmpty ||
//                               value.length < 8) {
//                             return 'Password must be greater than eight characters.';
//                           }
//                           return null;
//                         },
//                         decoration: const InputDecoration(
//                           hintText: 'Password',
//                         ),
//                       )
//                     ],
//                     if (state == 'new-email-needs-account') ...[
//                       TextFormField(
//                           controller: _firstNameController,
//                           decoration: const InputDecoration(
//                             hintText: 'First Name',
//                           ),
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'You must enter a first name.';
//                             }
//                             return null;
//                           }),
//                       TextFormField(
//                         controller: _lastNameController,
//                         decoration: const InputDecoration(
//                           hintText: 'Last Name',
//                         ),
//                       )
//                     ],
//                     const SizedBox(height: 16.0),
//                     ElevatedButton(
//                       //Assigned onPressed to submit
//                       onPressed: handleSubmit,
//                       //Conditionally show the button label
//                       child: Text(state == 'email-unknown'
//                           ? 'Next'
//                           : (state == 'new-email-needs-account'
//                               ? 'Sign up'
//                               : 'Login')),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           )),
//     );
//   }
// }






// class CustomCacheProvider extends CacheProvider {
//   @override
//   bool containsKey(String key, {String? defaultValue}) {
//     return Settings.getValue(key);
//   }

//   @override
//   bool? getBool(String key, {bool? defaultValue}) {
//     return Settings.getValue(key, defaultValue: true);
//   }

//   @override
//   double getDouble(String key, {double? defaultValue}) {
//     return Settings.getValue(key);
//   }

//   @override
//   int getInt(String key, {int? defaultValue}) {
//     return Settings.getValue(key);
//   }

//   @override
//   Set getKeys() {
//     throw UnimplementedError();
//   }

//   @override
//   String getString(String key, {String? defaultValue}) {
//     return Settings.getValue(key);
//   }

//   @override
//   T getValue<T>(String key, {T? defaultValue}) {
//     return Settings.getValue(key);
//   }

//   @override
//   Future<void> init() {
//     return Settings.init();
//   }

//   @override
//   Future<void> remove(String key, {Key? defaultValue}) {
//     Settings.getValue(key, defaultValue: 'hello');
//     throw UnimplementedError();
//   }

//   @override
//   Future<void> removeAll() {
//     // Needs to be done
//     throw UnimplementedError();
//   }

//   @override
//   Future<void> setBool(String key, bool? value) {
//     return Settings.setValue(key, value);
//   }

//   @override
//   Future<void> setDouble(String key, double? value) {
//     return Settings.setValue(key, value);
//   }

//   @override
//   Future<void> setInt(String key, int? value) {
//     return Settings.setValue(key, value);
//   }

//   @override
//   Future<void> setObject<T>(String key, T? value) {
//     return Settings.setValue(key, value);
//   }

//   @override
//   Future<void> setString(String key, String? value) {
//     return Settings.setValue(key, value);
//   }
// }
