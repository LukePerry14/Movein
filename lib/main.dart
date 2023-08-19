import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
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
import 'Auth code/auth.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

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
  static final ValueNotifier<ThemeMode> themeNotifier =
  ValueNotifier(ThemeMode.light);
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _loadSavedTheme();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    return ValueListenableBuilder<ThemeMode>(
        valueListenable: App.themeNotifier,
        builder: (context, currentMode, child) {
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            translations: AppTranslations(),
            locale: Get.deviceLocale,
            theme: LAppTheme.lightTheme,
            darkTheme: LAppTheme.darkTheme,
            themeMode: currentMode,
            initialRoute: FirebaseAuth.instance.currentUser == null
                ? '/Login'
                : '/Scroller',
            routes: {
              '/Login': (context) => const LoginScreen(),
              '/Signup': (context) => const SignupScreen(),
              '/Scroller': (context) => const Scroller(),
              '/ScrollRefresh': (context) => const RanOut(),
              '/Messages': (context) => const Messages(),
              '/Profile': (context) => const Profile(),
              '/Settings': (context) => const SettingsScaffold(),
              '/profileInformation': (context) => const ProfileInformation(),
              '/Friends': (context) => const Friends(),
              '/Houses': (context) => const Houses(),
              '/GroupOptions': (context) => const GroupOptions(),
              '/OnBoarding': (context) => const OnBoardingPage(),
            },
          );
        });
  }

  void _loadSavedTheme() {
    String? locale = UserPreferences.getLocale();

    Get.updateLocale(Locale(locale));


    bool? isDarkMode = UserPreferences.getBrightness();
    if (isDarkMode != null) {
      themeNotifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    }
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  String errorMessage = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            leading: null,
            expandedHeight: MediaQuery.of(context).size.height / 3,
            collapsedHeight: MediaQuery.of(context).size.height / 3,
            backgroundColor: LAppTheme.lightTheme.primaryColor,
            forceElevated: true,
            pinned: true,
            stretch: true,
            elevation: 40,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(
                'assets/Pictures/logo.png', // Replace with your image path
                fit: BoxFit.fitHeight,
              ),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.all(50.0),
              child: FormBuilder(
                key: _formKey,
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: Icon(LineAwesomeIcons.language, color: LAppTheme.lightTheme.primaryColor),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                contentPadding: const EdgeInsets.all(0),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(height:5),
                                    Stack(
                                      children: [
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: IconButton(
                                            icon: Icon(LineAwesomeIcons.angle_left, color: Theme.of(context).primaryColor),
                                            color: Colors.grey[500],
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ),
                                        Align(
                                            alignment: Alignment.bottomCenter,
                                            child: Text('language'.tr, style: Theme.of(context).textTheme.headlineSmall)
                                        ),
                                      ],
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.all(15.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          RadioLanguage(),
                                          SizedBox(height: 20),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 50),
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
                    Text(errorMessage),
                    const SizedBox(height: 5),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: LAppTheme.lightTheme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              20), // Adjust the radius as needed
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 24), // Adjust padding as needed
                      ),
                      onPressed: () async {
                        if (_formKey.currentState?.saveAndValidate() == false) {
                          return;
                        }

                        String response = await Auth()
                            .signInWithEmailAndPassword(
                            _formKey.currentState?.fields['email']?.value,
                            _formKey
                                .currentState?.fields['password']?.value);

                        if (response == 'success') {
                          final userDoc = await FirebaseFirestore.instance.collection('Users').doc(Auth().currentUser()).get();

                          if (userDoc.exists) {
                            final userData = userDoc.data() as Map<String, dynamic>?;

                            if (userData != null) {
                              final subscribed = userData['Subscribed'];
                              final uniAttended = userData['UniAttended'];
                              await UserPreferences.setAppsMax(subscribed? 5:3);
                              await UserPreferences.setUni(uniAttended);
                            }
                          }
                          Navigator.pushNamed(context, '/Scroller');
                          return;
                        } else {
                          setState(() {
                            var errors = {
                              'invalid-email': 'Enter a valid email',
                              'wrong-password': 'Incorrect password'
                            };
                            errorMessage = errors[response] ?? response;
                          });
                        }
                        return;
                      },
                      child: Text('Login',
                          style: GoogleFonts.redHatDisplay(
                              color: Colors.white, fontSize: 16.5)),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () async {
                        Navigator.pushNamed(context, '/Signup');
                      },
                      child: Text('Want to sign up instead?',
                          style: GoogleFonts.redHatDisplay(
                              color: LAppTheme.lightTheme.primaryColor,
                              fontSize: 16.5)),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
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
  late Timer _timer;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _passwordObscured = true;
  bool _passwordConfObscured = true;
  final _universityController = TextEditingController();
  final _universityFocusNode = FocusNode();
  bool _universityValid = true;
  bool _loadApp = false;
  String errorMessage = "";
  bool userInfoValid = false;
  bool profileInfoValid = false;
  bool preferenceInfoValid = false;
  late List<dynamic> universitiesData;
  late List<dynamic> domains;

  @override
  void initState() {
    super.initState();
    fetchJSON();

    _timer = Timer.periodic(const Duration(milliseconds: 500), (Timer timer) {
      _validateForm(); // Call your validation function here
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Theme.of(context).canvasColor,
              centerTitle: true,
              elevation: 0,
              floating: true,
              // Make the SliverAppBar automatically hide when scrolling down
              leading: IconButton(
                icon: Icon(LineAwesomeIcons.angle_left,
                    color: LAppTheme.lightTheme.primaryColor),
                color: Colors.grey[500],
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            SliverToBoxAdapter(
              child: !_loadApp ? Center(
                child: SizedBox(
                  width: MediaQuery.of(context)
                      .size
                      .width * 0.8, // Adjust the width to control the size
                  height: MediaQuery.of(context)
                      .size
                      .width * 0.8, // Adjust the height to control the size
                  child: const CircularProgressIndicator(),
                ),
              ): Padding(
                padding: const EdgeInsets.all(16.0),
                child: FormBuilder(
                  autovalidateMode: AutovalidateMode.always,
                  key: _formKey,
                  child: Column(
                    children: [
                      ListTile(
                        enableFeedback: false,
                        enabled: true,
                        leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Theme.of(context).primaryColor,
                                  width: 1),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Center(
                                child: Text("1",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.lexend(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 23)))),
                        title: Text("User Info",
                            style: Theme.of(context).textTheme.headlineSmall),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          children: [
                            FormBuilderTextField(
                              name: 'ForeName',
                              decoration: const InputDecoration(
                                  labelText: 'First Name'),
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
                              name: 'SurName',
                              decoration:
                              const InputDecoration(labelText: 'Last Name'),
                              // enabled: false,

                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your Surname';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),
                            FormBuilderTextField(
                              name: 'email',
                              controller: _emailController,
                              decoration: const InputDecoration(
                                  labelText: 'University Email'),
                              validator: (email) {
                                if (email == null || email.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!EmailValidator.validate(email)) {
                                  return 'Please enter a valid email address';
                                }
                                if (!domains
                                    .any((domain) => email.contains(domain))) {
                                  return 'Email domain is not valid';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: FormBuilderTextField(
                                    name: 'password',
                                    decoration: const InputDecoration(
                                        labelText: 'Password'),
                                    obscureText:
                                    _passwordObscured, // Use the variable to control the obscuring
                                    controller: _passwordController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your password';
                                      }
                                      if (value.length < 8) {
                                        return 'Password must be at least 8 characters long';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                IconButton(
                                  splashRadius: 20,
                                  onPressed: () {
                                    setState(() {
                                      _passwordObscured = !_passwordObscured;
                                    });
                                  },
                                  icon: Icon(_passwordObscured
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: FormBuilderTextField(
                                    name: 'password_conf',
                                    decoration: const InputDecoration(
                                        labelText: 'Confirm password'),
                                    obscureText:
                                    _passwordConfObscured, // Use the variable to control the obscuring
                                    controller: _passwordConfController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please Confirm your password';
                                      } else if (_passwordConfController.text !=
                                          _passwordController.text) {
                                        return "Passwords don't match";
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                IconButton(
                                  splashRadius: 20,
                                  onPressed: () {
                                    setState(() {
                                      _passwordConfObscured =
                                      !_passwordConfObscured;
                                    });
                                  },
                                  icon: Icon(_passwordConfObscured
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                      ListTile(
                        enableFeedback: false,
                        enabled: true,
                        leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: userInfoValid
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey,
                                  width: 1),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Center(
                                child: Text("2",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.lexend(
                                        color: userInfoValid
                                            ? Theme.of(context).primaryColor
                                            : Colors.grey,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 23)))),
                        title: Text("Profile Info",
                            style: GoogleFonts.lexend(
                                color: userInfoValid
                                    ? Colors.black87
                                    : Colors.grey,
                                fontWeight: FontWeight.normal,
                                fontSize: 20.0)),
                      ),
                      const SizedBox(height: 10),
                      if (userInfoValid)
                        Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            children: [
                              FormBuilderTextField(
                                name: 'Bio',
                                maxLength: 200,
                                decoration:
                                const InputDecoration(labelText: 'Bio'),
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
                                name: "DOB",
                                decoration: const InputDecoration(
                                    labelText: 'Date of Birth'),
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select a date';
                                  }

                                  final currentDate = DateTime.now();
                                  final selectedDate = value;
                                  final minimumAgeDate = DateTime(
                                      currentDate.year - 17,
                                      currentDate.month,
                                      currentDate.day);

                                  if (selectedDate.isAfter(minimumAgeDate)) {
                                    return 'You must be at least 17 years old';
                                  }

                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),
                              FormBuilderTextField(
                                name: 'Subject',
                                decoration: const InputDecoration(
                                    labelText: 'Subject Studied'),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your Subject';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),
                              TypeAheadFormField(
                                textFieldConfiguration: TextFieldConfiguration(
                                  decoration: const InputDecoration(
                                    labelText: 'University',
                                  ),
                                  controller: _universityController,
                                  focusNode: _universityFocusNode,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please select a university';
                                  }
                                  final universitiesSuggestions =
                                  universitiesData
                                      .map((university) =>
                                  university['name'])
                                      .toList();

                                  if (!universitiesSuggestions
                                      .contains(value)) {
                                    return 'Please select a valid university from the suggestions';
                                  }
                                  String emailDomain = _emailController.text.split('@')[1];

                                  // Check if the email domain is valid for the selected university
                                  Map<String, dynamic>? selectedUniversity = universitiesData
                                      .firstWhere((university) => university['name'] == value, orElse: () => null);
                                  if (selectedUniversity != null) {
                                    List<String>? validDomains = selectedUniversity['domains']?.cast<String>();
                                    if (validDomains != null && !validDomains.contains(emailDomain)) {
                                      return 'The selected university does not match the email domain';
                                    }
                                  }
                                  return null;
                                },
                                suggestionsCallback: (pattern) {
                                  // Return filtered universities based on the pattern
                                  return universitiesData
                                      .where((university) => university['name']
                                      .toLowerCase()
                                      .contains(pattern.toLowerCase()))
                                      .map((university) => university['name'])
                                      .toList();
                                },
                                itemBuilder: (context, suggestion) {
                                  return ListTile(
                                    title: Text(suggestion),
                                  );
                                },
                                onSuggestionSelected: (value) {
                                  _universityController.text = value;
                                  _universityFocusNode.unfocus();
                                  _validateUniversity(value);
                                },
                              ),
                              const SizedBox(height: 10),
                              FormBuilderSlider(
                                name: 'YearOfStudy',
                                initialValue: 1,
                                min: 1,
                                max: 7,
                                divisions: 6,
                                decoration: const InputDecoration(
                                    labelText: 'Year of Study'),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 25),
                      ListTile(
                        enableFeedback: false,
                        enabled: true,
                        leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: (userInfoValid & profileInfoValid)
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey,
                                  width: 1),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Center(
                                child: Text("3",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.lexend(
                                        color:
                                        (userInfoValid & profileInfoValid)
                                            ? Theme.of(context).primaryColor
                                            : Colors.grey,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 23)))),
                        title: Text("Preferences",
                            style: GoogleFonts.lexend(
                                color: (userInfoValid & profileInfoValid)
                                    ? Colors.black87
                                    : Colors.grey,
                                fontWeight: FontWeight.normal,
                                fontSize: 20.0)),
                      ),
                      const SizedBox(height: 10),
                      if (userInfoValid & profileInfoValid)
                        Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            children: [
                              FormBuilderSlider(
                                name: 'Cleanliness',
                                initialValue: 2,
                                min: 0,
                                max: 5,
                                divisions: 5,
                                decoration: const InputDecoration(
                                    labelText:
                                    'How much does Cleanliness matter to you?'),
                              ),
                              const SizedBox(height: 10),
                              FormBuilderSlider(
                                name: 'Noisiness',
                                initialValue: 2,
                                min: 0,
                                max: 5,
                                divisions: 5,
                                decoration: const InputDecoration(
                                    labelText:
                                    'How much does Noisiness matter to you?'),
                              ),
                              const SizedBox(height: 10),
                              FormBuilderSlider(
                                name: 'NightLife',
                                initialValue: 2,
                                min: 0,
                                max: 5,
                                divisions: 5,
                                decoration: const InputDecoration(
                                    labelText:
                                    'How much does Nightlife matter to you?'),
                              ),
                              const SizedBox(height: 10),
                              FormBuilderDateTimePicker(
                                name: 'Lights Out',
                                initialValue: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day,
                                    23,
                                    0), // 11:00 PM
                                inputType: InputType.time,
                                decoration: const InputDecoration(
                                    labelText: 'When are you normally in bed?'),
                                validator: (value) {
                                  if (value == null) {
                                    return "Please select a time you're asleep by";
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      Text(errorMessage),
                      const SizedBox(height: 5),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: (profileInfoValid &
                          userInfoValid &
                          preferenceInfoValid)
                              ? LAppTheme.lightTheme.primaryColor
                              : Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                20), // Adjust the radius as needed
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 24), // Adjust padding as needed
                        ),
                        onPressed: () async {
                          if (_formKey.currentState?.saveAndValidate() ==
                              false) {
                            return;
                          }
                          // debugPrint(_formKey.currentState?.value.toString());
                          Map<String,dynamic> data = Map<String,dynamic>.from(_formKey.currentState?.value ?? {});
                          data['UniAttended'] = _universityController.text;
                          Map<String,dynamic> reConfigedData = reConfigData(data);
                          String response =
                          await Auth().registerWithUserDetails(
                            _formKey.currentState?.fields['email']?.value,
                            _formKey.currentState?.fields['password']?.value,
                            reConfigedData,
                          );

                          if (response == 'success') {
                            await UserPreferences.setUni(data['UniAttended']);
                            await UserPreferences.setAppsMax(3);

                            Navigator.pushNamed(context, '/OnBoarding');
                            return;
                          } else {
                            setState(() {
                              var errors = {
                                'invalid-email': 'Enter a valid email',
                                'wrong-password': 'Incorrect password'
                              };
                              // error_message = errors[response] ?? response;
                            });
                          }
                          return;
                        },
                        child: Text('Signup',
                            style: GoogleFonts.redHatDisplay(
                                color: Colors.white, fontSize: 16.5)),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () async {
                          Navigator.pushNamed(context, '/OnBoarding');
                        },
                        child: const Text('Want to log in instead?'),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Future<void> fetchJSON() async {
    final String jsonContent = await rootBundle
        .loadString('assets/JSON/world_universities_and_domains.json');
    universitiesData = json.decode(jsonContent);
    domains = universitiesData
        .map<List<dynamic>>((university) => university['domains'])
        .expand((list) => list)
        .toList(); // Fetch the data when the widget is created
    setState(() {
      _loadApp = true;
    });
  }

  void _validateForm() {
    if(_loadApp) {
      _validateUniversity(_universityController.text);
      final userInfoComplete =
      (_formKey.currentState?.fields['ForeName']?.isValid ?? false) &
      (_formKey.currentState?.fields['SurName']?.isValid ?? false) &
      (_formKey.currentState?.fields['email']?.isValid ?? false) &
      (_formKey.currentState?.fields['password']?.isValid ?? false) &
      (_formKey.currentState?.fields['password_conf']?.isValid ?? false);

      // Check if profile info section fields are complete
      final profileInfoComplete =
      (_formKey.currentState?.fields['Bio']?.isValid ?? false) &
      (_formKey.currentState?.fields['DOB']?.isValid ?? false) &
      (_formKey.currentState?.fields['Subject']?.isValid ?? false) &
      (_universityValid) &
      (_formKey.currentState?.fields['YearOfStudy']?.isValid ?? false);

      final preferenceInfoComplete =
      (_formKey.currentState?.fields['Cleanliness']?.isValid ?? false) &
      (_formKey.currentState?.fields['Noisiness']?.isValid ?? false) &
      (_formKey.currentState?.fields['NightLife']?.isValid ?? false) &
      (_formKey.currentState?.fields['Lights Out']?.isValid ?? false);

      print(userInfoComplete);
      setState(() {
        userInfoValid = userInfoComplete;
        profileInfoValid = profileInfoComplete;
        preferenceInfoValid = preferenceInfoComplete;
      });
    }
  }

  void _validateUniversity(selectedUniversity) {
    bool temp = true;
    final universitiesSuggestions =
    universitiesData.map((university) => university['name']).toList();

    if (!universitiesSuggestions.contains(selectedUniversity)) {
      temp = false;
    }
    setState(() {
      _universityValid = temp;
    });
  }

  Map<String, dynamic> reConfigData(Map<String, dynamic> data) {
    data.remove('password');
    data.remove('password_conf');
    data.remove('email');
    data['Preferences'] = {'Noisiness': data['Noisiness'], 'Cleanliness': data['Cleanliness'], 'NightLife': data['NightLife'], 'Lights Out': data['Lights Out']};
    data.remove('Noisiness');
    data.remove('Cleanliness');
    data.remove('NightLife');
    data.remove('Lights Out');
    data['Applications'] = [];
    data['BlockedGroups'] = [];
    data['FriendInvites'] = [];
    data['Friends'] = [];
    data['GroupInvites'] = [];
    data['Groups'] = [];
    data['Joined'] = [];
    data['OutgoingFriendInvites'] = [];
    data['ShortList'] = [];
    data['Images'] = ["assets/Pictures/ph.png","assets/Pictures/ph.png","assets/Pictures/ph.png","assets/Pictures/ph.png","assets/Pictures/ph.png","assets/Pictures/ph.png"];
    data['Subscribed'] = false;
    return data;
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
