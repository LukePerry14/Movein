import 'dart:async';
import 'dart:convert';
import 'dart:io';
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
import 'package:movein/Pages/Settings.dart';
import 'package:movein/Pages/Sendbird.dart';
import 'package:movein/Pages/Notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:movein/Translations.dart';
import 'package:movein/UserPreferences.dart';
import 'package:provider/provider.dart';
import 'Auth code/auth.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'Auth code/auth.dart';
import 'package:azblob/azblob.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';
import 'package:azstore/azstore.dart' as AzureStorage;
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  //LinkFivePurchases.init("fae19762a8d0f160ead020291d33b644b70c69f576202d0c207d4a9153c72b7c");
  //LinkFivePurchases.products;
  //LinkFivePurchases.activeProducts;
  //LinkFivePurchases.purchase(productDetails);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await UserPreferences.init();


  runApp(const App());
}

class App extends StatelessWidget {
  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);
  const App({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
      _loadSavedTheme();
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: App.themeNotifier),
          ChangeNotifierProvider(create: (_) => FriendsTrigger()),
          //ChangeNotifierProvider(create: (context) => LinkFiveProvider("fae19762a8d0f160ead020291d33b644b70c69f576202d0c207d4a9153c72b7c"), lazy: false,),
        ],
        child: ValueListenableBuilder<ThemeMode>(
            valueListenable: App.themeNotifier,
            builder: (context, currentMode, child) {
              final String foreName = UserPreferences.getForeName();
              final bool loggedIn = (foreName != "NotLoggedInError");
              if (foreName != "NotLoggedInError") {
                //ACCESS_TOKEN
                ConnectSendbird().connect("33BDBE40-0D0C-4529-BA3B-74C0916D2682", Auth().currentUser(), foreName);
              }
              return GetMaterialApp(
                debugShowCheckedModeBanner: false,
                translations: AppTranslations(),
                locale: Get.deviceLocale,
                theme: LAppTheme.lightTheme,
                darkTheme: LAppTheme.darkTheme,
                themeMode: currentMode,
                initialRoute: !loggedIn
                    ? '/Login'
                    : '/Scroller',
                  routes: {
                    '/OnBoarding': (context) => const OnBoardingPage(),
                  },

                  onGenerateInitialRoutes: (initialRoute) {
                    if (initialRoute == '/Scroller') {
                      return [MaterialPageRoute(builder: (context) => const Scroller())];
                    }
                    else {
                      return [MaterialPageRoute(builder: (context) => const LoginScreen())];
                    }
                  }
              );
            }),
      );
  }
// fix size of image
  void _loadSavedTheme() {
    String? locale = UserPreferences.getLocale();

    Get.updateLocale(Locale(locale));


    bool? isDarkMode = UserPreferences.getBrightness();
    if (isDarkMode != null) {
      App.themeNotifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    }
  }
}

class FriendsTrigger with ChangeNotifier {
  bool _friendsRebuildTrigger = false;

  bool get trigger => _friendsRebuildTrigger;

  void flip() {
    _friendsRebuildTrigger = !_friendsRebuildTrigger;
    notifyListeners();
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
            automaticallyImplyLeading: false,
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
                      decoration: InputDecoration(labelText: 'email'.tr),
                      // enabled: false,

                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'email_null'.tr;
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
                      decoration: InputDecoration(labelText: 'password'.tr),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'password-null'.tr;
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
                              await UserPreferences.setAppsMax(subscribed? 5:2);
                              await UserPreferences.setUni(userData['UniAttended']);
                              await UserPreferences.setForeName(userData['ForeName']);
                              //ACCESS_TOKEN
                              ConnectSendbird().connect("33BDBE40-0D0C-4529-BA3B-74C0916D2682", Auth().currentUser(),userData['ForeName']);
                              if (SendbirdChat.getPendingPushToken() != null)
                              {await Notifications.registerPushToken();}

                            }
                          }
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.fade,
                            child: const Scroller(),
                            isIos: true,
                            duration: Duration(milliseconds: 400),
                          ),
                        );
                          return;
                        } else {
                          setState(() {
                            var errors = {
                              'invalid-email': 'invalid-email'.tr,
                              'wrong-password': 'wrong-password'.tr
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
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child: const SignupScreen(),
                            duration: const Duration(seconds: 1),
                            reverseDuration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Text('signup?'.tr,
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

  File? _profilePicture1;
  File? _profilePicture2;
  File? _profilePicture3;

  String? _profilePicture1String;
  String? _profilePicture2String;
  String? _profilePicture3String;

  var defaultProfilePicture = Image.asset('assets/Pictures/turt.png');

  var uuid = const Uuid();

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
  late List<dynamic> universitiesSuggestions;

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

  Future<void> _uploadImageToAzure(File imageFile) async {
  Uint8List bytes = imageFile.readAsBytesSync();
    var x = AzureStorage.AzureStorage.parse(
        'DefaultEndpointsProtocol=https;AccountName=movein;AccountKey=4MaJcz+DSy+KHInVIhTmtzj3OoWtTr0E+IDAjajCliKTaS5X5j3q2Rp69Q/oDiPtzGXfWw3OJPYh+ASt9PPo9w==;EndpointSuffix=core.windows.net');
    try {
      var uuid = const Uuid();
      String imageName = uuid.v1();
      await x.putBlob('/moveinimages/$imageName.jpg',
          contentType: 'image/jpg', bodyBytes: bytes);
    } catch (e) {
      print('Exception: $e');
    }
  }

  Future<File?> pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      return File(image.path);
    } else {
      print('No image selected.');
      return null;
    }
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
                        title: Text('user_info'.tr,
                            style: Theme.of(context).textTheme.headlineSmall),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          children: [
                            FormBuilderTextField(
                              name: 'ForeName',
                              decoration: InputDecoration(
                                  labelText: 'first-name'.tr),
                              // enabled: false,

                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'first-name-null'.tr;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10),
                            FormBuilderTextField(
                              name: 'SurName',
                              decoration:
                              InputDecoration(labelText: 'last-name'.tr),
                              // enabled: false,

                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'last-name-null'.tr;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),
                            FormBuilderTextField(
                              name: 'email',
                              controller: _emailController,
                              decoration: InputDecoration(
                                  labelText: 'uni-email'.tr),
                              validator: (email) {
                                if (email == null || email.isEmpty) {
                                  return 'email_null'.tr;
                                }
                                if (!EmailValidator.validate(email)) {
                                  return 'uni-email-invalid'.tr;
                                }
                                if (!domains
                                    .any((domain) => email.contains(domain))) {
                                  return 'uni-email-domain-invalid'.tr;
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
                                    decoration: InputDecoration(
                                        labelText: 'password'.tr),
                                    obscureText:
                                    _passwordObscured, // Use the variable to control the obscuring
                                    controller: _passwordController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'password-null'.tr;
                                      }
                                      if (value.length < 8) {
                                        return 'password-too-short'.tr;
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
                                        return 'password-conf'.tr;
                                      } else if (_passwordConfController.text !=
                                          _passwordController.text) {
                                        return 'password-mismatch'.tr;
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
                        title: Text('profile-info'.tr,
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
                                InputDecoration(labelText: 'bio'.tr),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'bio-null'.tr;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),
                              // This is where the profile images go
                              const Text('Profile Photo'),
                              const SizedBox(height: 10),
                              Container(
                                child:  _profilePicture1 == null ? defaultProfilePicture : Image.file(_profilePicture1!),
                              ),
                              const SizedBox(height: 20),
                              // Container for image
                              ElevatedButton(
                                onPressed: () async {
                                  final pickedImage = await pickImage();
                                  if (_profilePicture1 != null) {
                                    _profilePicture1String = uuid.v1();
                                    setState(() {
                                      _profilePicture1 = pickedImage;
                                    });
                                  }
                                },
                                child: const Icon(Icons.edit)
                              ),
                              const Text('Second Image'),
                              const SizedBox(height: 10),
                              Container(
                                child:  _profilePicture2 == null ? defaultProfilePicture : Image.file(_profilePicture2!),
                              ),
                              const SizedBox(height: 20),
                              // Container for second image
                              ElevatedButton(
                                onPressed: () async { 
                                  final pickedImage = await pickImage();
                                  if (_profilePicture2 != null) {
                                    _profilePicture2String = uuid.v1();
                                    setState(() {
                                      _profilePicture2 = pickedImage;
                                    });
                                  }
                                }, 
                                child: const Icon(Icons.edit)
                              ),
                              const SizedBox(height: 10),
                              const Text('Third Picture'),
                              const SizedBox(height: 10),
                              Container(
                                child:  _profilePicture3 == null ? defaultProfilePicture : Image.file(_profilePicture3!),
                              ),
                              const SizedBox(height: 20),
                              // container for third picture
                              ElevatedButton(
                                onPressed: () async {
                                  final _profilePicture3 = await pickImage();
                                  if (_profilePicture3 != null) {
                                    _profilePicture3String = uuid.v1();
                                  }
                                }, 
                                child: const Icon(Icons.edit)
                              ),
                              const SizedBox(height: 10),
                              FormBuilderDateTimePicker(
                                inputType: InputType.date,
                                name: "DOB",
                                decoration: InputDecoration(
                                    labelText: 'dob'.tr),
                                validator: (value) {
                                  if (value == null) {
                                    return 'dob-null'.tr;
                                  }

                                  final currentDate = DateTime.now();
                                  final selectedDate = value;
                                  final minimumAgeDate = DateTime(
                                      currentDate.year - 17,
                                      currentDate.month,
                                      currentDate.day);

                                  if (selectedDate.isAfter(minimumAgeDate)) {
                                    return 'too-young'.tr;
                                  }

                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),
                              FormBuilderTextField(
                                name: 'Subject',
                                decoration: InputDecoration(
                                    labelText: 'subject-studied'.tr),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'subject-null'.tr;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),
                              TypeAheadFormField(
                                textFieldConfiguration: TextFieldConfiguration(
                                  decoration: InputDecoration(
                                    labelText: 'uni'.tr,
                                  ),
                                  controller: _universityController,
                                  focusNode: _universityFocusNode,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'uni-null'.tr;
                                  }
                                  final universitiesSuggestions =
                                  universitiesData
                                      .map((university) =>
                                  university['name'])
                                      .toList();

                                  if (!universitiesSuggestions
                                      .contains(value)) {
                                    return 'uni-unregisterd'.tr;
                                  }
                                  String emailDomain = _emailController.text.split('@')[1];

                                  // Check if the email domain is valid for the selected university
                                  Map<String, dynamic>? selectedUniversity = universitiesData
                                      .firstWhere((university) => university['name'] == value, orElse: () => null);
                                  if (selectedUniversity != null) {
                                    List<String>? validDomains = selectedUniversity['domains']?.cast<String>();
                                    if (validDomains != null && !validDomains.contains(emailDomain)) {
                                      return 'uni-unmatched'.tr;
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
                                decoration: InputDecoration(
                                    labelText: 'year-of-study'.tr),
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
                        title: Text("preferences".tr,
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
                                decoration: InputDecoration(
                                    labelText:
                                    'cleanliness-importance'.tr),
                              ),
                              const SizedBox(height: 10),
                              FormBuilderSlider(
                                name: 'Noisiness',
                                initialValue: 2,
                                min: 0,
                                max: 5,
                                divisions: 5,
                                decoration: InputDecoration(
                                    labelText:
                                    'noisiness-importance'.tr),
                              ),
                              const SizedBox(height: 10),
                              FormBuilderSlider(
                                name: 'NightLife',
                                initialValue: 2,
                                min: 0,
                                max: 5,
                                divisions: 5,
                                decoration: InputDecoration(
                                    labelText:
                                    'nightlife-importance'.tr),
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
                                decoration: InputDecoration(
                                    labelText: 'bedtime'.tr),
                                validator: (value) {
                                  if (value == null) {
                                    return 'bedtime-select'.tr;
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
                            //ACCESS_TOKEN
                            ConnectSendbird().connect("33BDBE40-0D0C-4529-BA3B-74C0916D2682", Auth().currentUser(), data['ForeName']);

                            await UserPreferences.setUni(data['UniAttended']);
                            await UserPreferences.setAppsMax(2);
                            await UserPreferences.setForeName(data['ForeName']);

                            Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: const OnBoardingPage(), duration: const Duration(milliseconds: 200)));
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

    universitiesSuggestions = universitiesData.map((university) => university['name']).toList();
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

      setState(() {
        userInfoValid = userInfoComplete;
        profileInfoValid = profileInfoComplete;
        preferenceInfoValid = preferenceInfoComplete;
      });
    }
  }

  void _validateUniversity(selectedUniversity) {
    bool temp = true;

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