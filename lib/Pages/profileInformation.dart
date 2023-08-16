import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import '../Auth code/auth.dart';
import '../Themes/lMode.dart';
import '../main.dart';

class ProfileInformation extends StatefulWidget {
  const ProfileInformation({super.key});

  @override
  State<ProfileInformation> createState() => _ProfileInformationState();
}

class _ProfileInformationState extends State<ProfileInformation> {
  final _formKey = GlobalKey<FormBuilderState>();
  late Timer _timer;
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController _passwordConfController = TextEditingController();
  List<bool> expansionTileStates = [false, false, false];


  bool _passwordObscured = true;
  bool _passwordConfObscured = true;

  String errorMessage = "";
  bool formValid = true;
  Map<String, dynamic> userData = {
    'ForeName': "",
    'SurName': "",
    'Bio': "",
    'DOB': null,
    'Subject': "",
    'YearOfStudy': 1.0,
    'Preferences': {
      'Cleanliness': 1.0,
      'Noisiness': 1.0,
      'NightLife': 1.0,
      'Lights Out': null,
    }
  };

  @override
  void initState() {
    super.initState();
    getUserData();
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
      bool isDark = App.themeNotifier.value == ThemeMode.dark;
      if (userData['DOB'] == null) {
        return Container();
      } else {
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
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FormBuilder(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    key: _formKey,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              LineAwesomeIcons.user,
                              color: isDark? Colors.white70 : Theme.of(context).primaryColor,
                              size: 50,
                            ),
                            const SizedBox(width: 10),
                            Text("edit_profile".tr,
                                style:
                                    Theme.of(context).textTheme.headlineLarge)
                          ],
                        ),
                        const Divider(height: 20, thickness: 1),
                        const SizedBox(height: 10),
                        Theme(
                          data: Theme.of(context)
                              .copyWith(
                              dividerColor: Colors.transparent,
                          ),
                          child: ExpansionTile(
                            initiallyExpanded: expansionTileStates[0],
                            onExpansionChanged: (newState) {
                              setState(() {
                                expansionTileStates[0] = newState;
                              });
                            },
                            leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: LAppTheme.lightTheme.primaryColor,
                                      width: 1),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Center(
                                    child: Text("1",
                                        textAlign: TextAlign.center,
                                        style: isDark? Theme.of(context).textTheme.headlineSmall :GoogleFonts.lexend(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 23)))),
                            title: Text("User Info",
                                style:
                                    Theme.of(context).textTheme.headlineSmall),
                            children: [
                              const SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.all(15),
                                child: Column(
                                  children: [
                                    FormBuilderTextField(
                                      name: 'ForeName',
                                      initialValue: userData['ForeName'],
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
                                      initialValue: userData['SurName'],
                                      decoration: const InputDecoration(
                                          labelText: 'Last Name'),
                                      // enabled: false,

                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your Surname';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),
                        Theme(
                          data: Theme.of(context)
                              .copyWith(dividerColor: Colors.transparent,
                          ),
                          child: ExpansionTile(
                            initiallyExpanded: expansionTileStates[1],
                            onExpansionChanged: (newState) {
                              setState(() {
                                expansionTileStates[1] = newState;
                              });
                            },
                            leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: LAppTheme.lightTheme.primaryColor,
                                      width: 1),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Center(
                                    child: Text("2",
                                        textAlign: TextAlign.center,
                                        style: isDark? Theme.of(context).textTheme.headlineSmall :GoogleFonts.lexend(
                                            color:
                                            Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 23)))),
                            title: Text("Profile Info",
                                style: Theme.of(context).textTheme.headlineSmall),
                            children: [
                              const SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.all(15),
                                child: Column(
                                  children: [
                                    FormBuilderTextField(
                                      name: 'Bio',
                                      initialValue: userData['Bio'],
                                      maxLength: 200,
                                      decoration: const InputDecoration(
                                          labelText: 'Bio'),
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
                                      enabled: false,
                                      initialValue: (userData['DOB'] == null)
                                          ? null
                                          : userData['DOB'].toDate(),
                                      name: "DOB",
                                      decoration: const InputDecoration(
                                          labelText: 'Date of Birth'),
                                    ),
                                    const SizedBox(height: 10),
                                    FormBuilderTextField(
                                      name: 'Subject',
                                      initialValue: userData['Subject'],
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
                                    TextFormField(
                                      enabled: false,
                                      initialValue: userData['UniAttended'],
                                      //university area
                                    ),
                                    const SizedBox(height: 10),
                                    FormBuilderSlider(
                                      name: 'YearOfStudy',
                                      initialValue: userData['YearOfStudy'],
                                      min: 1,
                                      max: 7,
                                      divisions: 6,
                                      decoration: const InputDecoration(
                                          labelText: 'Year of Study'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),
                        Theme(
                          data: Theme.of(context)
                              .copyWith(dividerColor: Colors.transparent,
                          ),
                          child: ExpansionTile(
                            initiallyExpanded: expansionTileStates[2],
                            onExpansionChanged: (newState) {
                              setState(() {
                                expansionTileStates[2] = newState;
                              });
                            },
                            leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: LAppTheme.lightTheme.primaryColor,
                                      width: 1),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Center(
                                    child: Text("3",
                                        textAlign: TextAlign.center,
                                        style: isDark? Theme.of(context).textTheme.headlineSmall :GoogleFonts.lexend(
                                            color:
                                            Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 23)))),
                            title: Text("Preferences",
                                style: Theme.of(context).textTheme.headlineSmall),
                            children: [
                              const SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.all(15),
                                child: Column(
                                  children: [
                                    FormBuilderSlider(
                                      name: 'Cleanliness',
                                      initialValue: userData['Preferences']
                                          ['Cleanliness'],
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
                                      initialValue: userData['Preferences']
                                          ['Noisiness'],
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
                                      initialValue: userData['Preferences']['NightLife'],
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
                                      initialValue: (userData['Preferences']
                                                  ['Lights Out'] ==
                                              null)
                                          ? null
                                          : userData['Preferences']
                                                  ['Lights Out']
                                              .toDate(),
                                      inputType: InputType.time,
                                      decoration: const InputDecoration(
                                          labelText:
                                              'When are you normally in bed?'),
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
                            ],
                          ),
                        ),
                        Text(errorMessage),
                        const SizedBox(height: 5),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: formValid
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
                            if (formValid) {
                              await updateInfo();
                              Navigator.of(context).pushReplacementNamed('/Profile');
                            }
                          },
                          child: Text('Save Changes',
                              style: GoogleFonts.redHatDisplay(
                                  color: Colors.white, fontSize: 16.5)),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    });
  }

  void getUserData() async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('Users') // Replace 'Users' with your collection name
          .doc(Auth().currentUser()) // Replace 'yes' with your document ID
          .get();

      if (docSnapshot.exists) {
        Map<String, dynamic>? data = docSnapshot.data() as Map<String, dynamic>?;
        userData = {
          "ForeName": data?['ForeName'],
          "SurName": data?['SurName'],
          "Uni": data?['UniAttended'],
          "DOB": data?['DOB'],
          "Preferences": {
            "Cleanliness" : (data?['Preferences']['Cleanliness'] as num).toDouble(),
            "Noisiness" : (data?['Preferences']['Noisiness'] as num).toDouble(),
            "NightLife" : (data?['Preferences']['NightLife'] as num).toDouble(),
            "Lights Out" : data?['Preferences']['Lights Out']
          },
          "Images": data?['Images'],
          "Bio": data?['Bio'],
          "Subject": data?['Subject'],
          "YearOfStudy": (data?['YearOfStudy'] as num).toDouble(),
        };
        setState(() {});
      }
    } catch (e) {
      throw FirebaseException(
        message: 'Error getting userData: $e',
        plugin: 'cloud_firestore',
      );
    }
  }

  void _validateForm() {
    bool uservalid = true;
    bool profileValid = true;
    bool prefsValid = true;
    if (expansionTileStates.contains(true)){
      if(expansionTileStates[0] == true){
        uservalid = (_formKey.currentState?.fields['ForeName']?.isValid ?? false) &
        (_formKey.currentState?.fields['SurName']?.isValid ?? false);
        userData['ForeName'] = _formKey.currentState?.fields['ForeName']?.value;
        userData['SurName'] = _formKey.currentState?.fields['SurName']?.value;
      }
      if(expansionTileStates[1] == true){
        profileValid = (_formKey.currentState?.fields['Bio']?.isValid ?? false) &
        (_formKey.currentState?.fields['Subject']?.isValid ?? false) &
        (_formKey.currentState?.fields['YearOfStudy']?.isValid ?? false);
        userData['Bio'] = _formKey.currentState?.fields['Bio']?.value;
        userData['Subject'] = _formKey.currentState?.fields['Subject']?.value;
        userData['YearOfStudy'] = _formKey.currentState?.fields['YearOfStudy']?.value;
      }
      if(expansionTileStates[2] == true){
        uservalid = (_formKey.currentState?.fields['Cleanliness']?.isValid ?? false) &
        (_formKey.currentState?.fields['Noisiness']?.isValid ?? false) &
        (_formKey.currentState?.fields['NightLife']?.isValid ?? false) &
        (_formKey.currentState?.fields['Lights Out']?.isValid ?? false);
        userData['Preferences']['Cleanliness'] = _formKey.currentState?.fields['Cleanliness']?.value;
        userData['Preferences']['Noisiness'] = _formKey.currentState?.fields['Noisiness']?.value;
        userData['Preferences']['NightLife'] = _formKey.currentState?.fields['NightLife']?.value;
        userData['Preferences']['Lights Out'] = Timestamp.fromDate(_formKey.currentState?.fields['Lights Out']?.value);
      }
    }
    final confFormvalid = uservalid & profileValid & prefsValid;
    setState(() {
      formValid = confFormvalid;
    });
  }

  Future<void> updateInfo() async {
    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(Auth().currentUser())
          .update({
        'ForeName': userData['ForeName'],
        'SurName': userData['SurName'],
        'Bio': userData['Bio'],
        'DOB': userData['DOB'],
        'Subject': userData['Subject'],
        'YearOfStudy': userData['YearOfStudy'],
        'Preferences': {
          'Cleanliness': userData['Preferences']['Cleanliness'],
          'Noisiness': userData['Preferences']['Noisiness'],
          'NightLife': userData['Preferences']['NightLife'],
          'Lights Out': userData['Preferences']['Lights Out'],
        }
      });

    } catch (e) {
      throw FirebaseException(
        message: 'Error saving user data: $e',
        plugin: 'cloud_firestore',
      );
    }
  }
}
