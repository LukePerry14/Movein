// ignore_for_file: camel_case_types
import 'package:cloud_firestore/cloud_firestore.dart';

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movein/Pages/Settings.dart';
import 'package:movein/Pages/profileInformation.dart';
import 'package:movein/UserPreferences.dart';
import 'package:movein/navbar.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mime/mime.dart';
import 'package:http/http.dart' as http;
import 'package:azstore/azstore.dart' as AzureStorage;
import 'package:uuid/uuid.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';

import '../Auth code/auth.dart';
import '../Themes/lMode.dart';
import '../main.dart';
import 'Friends.dart';
import 'PremiumPage.dart';
import 'Scroller.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfilePage();
}

class _ProfilePage extends State<Profile> {
  var data;
  File? _profileImage;
  File? accountPicture1;
  File? accountPicture2;
  String? accountPicture1String;
  String? accountPicture2String;
  String? _defaultProfileImagePath = 'assets/Pictures/turt.png';
  final TextEditingController _copyController = TextEditingController();

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: _copyController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'copied'.tr,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        backgroundColor: Theme.of(context).primaryColor,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<List<String>> getNameAndPic() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("Users")
          .doc(Auth().currentUser())
          .get();

      String foreName = userDoc.get("ForeName");
      String surname = userDoc.get("SurName");
      String profPic = userDoc.get("Images")[0];
      String picture1 = userDoc.get("Images")[1];
      String picture2 = userDoc.get("Images")[2];
      String fullName = "$foreName $surname";

      return [fullName, profPic, picture1, picture2];
    } catch (e) {
      throw FirebaseException(
          message: 'Error retrieving name or profile picture: $e',
          plugin: 'cloud_firestore');
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

  // For returning the string name for firebase upload
  Future<String?> _uploadImageToAzure2(File imageFile) async {
    Uint8List bytes = imageFile.readAsBytesSync();
    var x = AzureStorage.AzureStorage.parse(
        'DefaultEndpointsProtocol=https;AccountName=movein;AccountKey=4MaJcz+DSy+KHInVIhTmtzj3OoWtTr0E+IDAjajCliKTaS5X5j3q2Rp69Q/oDiPtzGXfWw3OJPYh+ASt9PPo9w==;EndpointSuffix=core.windows.net');
    try {
      var uuid = const Uuid();
      String imageName = uuid.v1();
      await x.putBlob('/moveinimages/$imageName.jpg', contentType: 'image/jpg', bodyBytes: bytes);
      return '$imageName.jpg';
    } catch (e) {
      return ('Exception: $e');
    }
  }

  Future<void> _deleteProfileImageFromAzure(String fileString) async {
    var x = AzureStorage.AzureStorage.parse(
      'DefaultEndpointsProtocol=https;AccountName=movein;AccountKey=4MaJcz+DSy+KHInVIhTmtzj3OoWtTr0E+IDAjajCliKTaS5X5j3q2Rp69Q/oDiPtzGXfWw3OJPYh+ASt9PPo9w==;EndpointSuffix=core.windows.net'
      );
    try {
      await x.deleteBlob('/moveinimages/$fileString.jpg');
    } catch (e) {
      print('Exception: $e');
    }
  }

  GestureDetector buildChangeImages(BuildContext context) {
  var defaultProfilePicture = Image.asset('assets/Pictures/turt.png');
  return GestureDetector(
    onTap: () {
      showDialog(context: context, builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            centerTitle: true,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(LineAwesomeIcons.angle_left, color: Colors.white,),
              color: Colors.grey[500],
              onPressed: (() {
                Navigator.pop(context);
              })
            ),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  Text('change-account-images'.tr, style: Theme.of(context).textTheme.headlineMedium,),
                  const SizedBox(height: 20),
                  Container(
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: accountPicture1 == null ? defaultProfilePicture : Image.file(accountPicture1!),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final pickedImage = await pickImage();
                      if (pickedImage != null) {
                        // MUST DELETE OLD IMAGE
                        accountPicture1String = _uploadImageToAzure2(pickedImage) as String?;
                        // to be added to Images[1]
                        setState(() {
                          accountPicture1 = pickedImage;
                        });
                      }
                    },
                    child: Icon(Icons.edit),
                  ), 
                  const SizedBox(height: 20,),
                  Container(
                    decoration: const BoxDecoration(shape:  BoxShape.circle),
                    child: accountPicture2 == null? defaultProfilePicture : Image.file(accountPicture2!),
                  ), 
                  ElevatedButton(
                    onPressed: () async {
                      final pickedImage = await pickImage();
                      if (pickedImage != null) {
                        // MUST DELETE OLD
                        accountPicture1String =  _uploadImageToAzure2(pickedImage) as String?;
                        // To be added to Images[2]
                        setState(() {
                          accountPicture2 = pickedImage;
                        });
                      }
                    },
                    child: Icon(Icons.edit),
                  ),
                ],
              ),
            ),
          ),
        );
      });
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
        future: getNameAndPic(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            data = snapshot.data;
            var name = data[0];
            var profPic = data[1];
            // Other images for the user
            var image1 = data[2];
            var image2 = data[3];
            var defaultProfilePicture = Image.asset('assets/Pictures/turt.png');
            return Builder(builder: (context) {
              final navigator = Navigator.of(context);
              bool isDark = App.themeNotifier.value == ThemeMode.dark;
              return Scaffold(
                body: Stack(
                  children: [
                    SingleChildScrollView(
                      child: SafeArea(
                        child: Container(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              const SizedBox(height:10),
                              SizedBox(
                                width: 150, 
                                height:150, 
                                child: Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  child: _profileImage == null ? defaultProfilePicture : Image.file(_profileImage!)
                                )
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(onPressed: () async {
                                    final pickedImage = await pickImage();
                                    if (pickedImage != null) {
                                      await _uploadImageToAzure(pickedImage);
                                      setState(() {
                                        _profileImage = pickedImage;
                                      });
                                    }
                                }, child: const Icon(
                                  Icons.edit,
                                ),),
                              ),
                              const SizedBox(height:10),
                              Padding(padding: const EdgeInsets.all(8.0),
                                child: buildChangeImages(context),
                              ),
                              const SizedBox(height: 20.0),
                              Text(name,
                                  style: Theme.of(context).textTheme.headlineMedium),
                              const SizedBox(height: 8.0),
                              Row(mainAxisSize: MainAxisSize.min, children: [
                                GestureDetector(
                                  onTap: () => _copyToClipboard(context),
                                  child: Container(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      Auth().currentUser(),
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _copyToClipboard(context),
                                  child: const Icon(Icons.copy),
                                ),
                              ]),
                              const SizedBox(height: 50.0),
                              GestureDetector(
                                onTap: () => Navigator.push(context,PageTransition(curve:Curves.linear,type: PageTransitionType.bottomToTop, child:const Premium())),
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius:
                                      const BorderRadius.all(Radius.circular(42)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: LAppTheme.lightTheme.primaryColor
                                              .withAlpha(200),
                                          offset: const Offset(0, 20),
                                          blurRadius: 30,
                                          spreadRadius: -5,
                                        ),
                                      ],
                                      gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            LAppTheme.lightTheme.primaryColor
                                                .withAlpha(150),
                                            LAppTheme.lightTheme.primaryColor
                                                .withAlpha(200),
                                            LAppTheme.lightTheme.primaryColor,
                                            LAppTheme.lightTheme.primaryColor,
                                          ],
                                          stops: const [
                                            0.1,
                                            0.3,
                                            0.9,
                                            1.0
                                          ])),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 15,
                                        horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.125),
                                    child: Text('upgrade'.tr,
                                        style: GoogleFonts.redHatDisplay(
                                            color: Colors.grey[100], fontSize: 16.5)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 35.0),
                              Divider(
                                height: 1,
                                color: Colors.grey.withOpacity(0.3),
                              ),
                              const SizedBox(height: 35.0),
                              ListTile(
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: isDark
                                            ? Colors.white70
                                            : Theme.of(context).primaryColor,
                                        width: 1),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Icon(LineAwesomeIcons.user,
                                      color: isDark
                                          ? Colors.white70
                                          : Theme.of(context).primaryColor),
                                ),
                                title: Text(
                                  "edit_profile".tr,
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                                trailing: Icon(LineAwesomeIcons.angle_right,
                                    color: LAppTheme.lightTheme.primaryColor),
                                onTap: () {
                                  Navigator.push(context, PageTransition(
                                    type: PageTransitionType.rightToLeftWithFade,
                                    alignment: Alignment.topCenter,
                                    child: const ProfileInformation(),
                                    duration: const Duration(milliseconds: 400),
                                    reverseDuration: const Duration(milliseconds: 400),
                                  ),);
                                },
                              ),
                              const SizedBox(height: 30.0),
                              ListTile(
                                  leading: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: isDark
                                              ? Colors.white70
                                              : Theme.of(context).primaryColor,
                                          width: 1),
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Icon(LineAwesomeIcons.cog,
                                        color: isDark
                                            ? Colors.white70
                                            : Theme.of(context).primaryColor),
                                  ),
                                  title: Text(
                                    "settings".tr,
                                    style: Theme.of(context).textTheme.headlineSmall,
                                  ),
                                  trailing: Icon(LineAwesomeIcons.angle_right,
                                      color: LAppTheme.lightTheme.primaryColor),
                                  onTap: () {
                                    Navigator.push(context, PageTransition(
                                      type: PageTransitionType.rightToLeftWithFade,
                                      alignment: Alignment.topCenter,
                                      child: const SettingsScaffold(),
                                      duration: const Duration(milliseconds: 400),
                                      reverseDuration: const Duration(milliseconds: 400),
                                    ),);
                                  }),
                              const SizedBox(height: 30),
                              ListTile(
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.red, width: 1),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: const Icon(
                                      LineAwesomeIcons.alternate_sign_out,
                                      color: Colors.red),
                                ),
                                title: Text("log_out".tr,
                                    style: GoogleFonts.lexend(
                                        color: Colors.red,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 20.0)),
                                onTap: () async {
                                  await storageReset();
                                  await UserPreferences.setForeName(
                                      "NotLoggedInError");
                                  FirebaseAuth.instance.signOut();
                                  Navigator.pushReplacement(
                                    context, PageTransition(
                                    type: PageTransitionType.fade,
                                    child: const LoginScreen(),
                                    duration: Duration(milliseconds: 400),
                                  ),);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: CustomNavbar(
                        onItemSelected: (route) {
                          switch (route){
                            case '/Scroller':
                              Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.leftToRightJoined, child: const Scroller(), childCurrent: widget, duration: const Duration(milliseconds: 200)));
                              break;

                            case '/Friends':
                              Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.leftToRightJoined, child: const Friends(), childCurrent: widget, duration: const Duration(milliseconds: 200)));
                              break;

                            case '/Profile':
                              Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: const Profile(), duration: const Duration(milliseconds: 200)));
                          }
                          navigator.pushReplacementNamed(route);
                        },
                      ),
                    ),
                  ],
                ),
              );
            });
          }
        });
  }
}

class ButtonWidget extends StatelessWidget {
  final String text;
  final VoidCallback onClicked;

  const ButtonWidget({
    Key? key,
    required this.text,
    required this.onClicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 62, vertical: 22),
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      onPressed: onClicked,
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall,
      ));
}

class ButtonWidgetProfileInformation extends StatelessWidget {
  final String text;
  final VoidCallback onClicked;

  const ButtonWidgetProfileInformation(
      {Key? key, required this.text, required this.onClicked})
      : super(key: key);

  Widget build(BuildContext context) => ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: const StadiumBorder(),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 22),
      ),
      onPressed: onClicked,
      child: Row(children: <Widget>[
        const Icon(
          LineAwesomeIcons.user,
        ),
        const SizedBox(
          width: 10,
        ),
        Text(text)
      ]));
}

class ButtonWidgetSettings extends StatelessWidget {
  final String text;
  final VoidCallback onClicked;

  const ButtonWidgetSettings(
      {Key? key, required this.text, required this.onClicked})
      : super(key: key);

  @override
  Widget build(BuildContext context) => ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: const StadiumBorder(),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 22),
      ),
      onPressed: onClicked,
      child: Row(children: <Widget>[
        const Icon(
          LineAwesomeIcons.cog,
        ),
        const SizedBox(
          width: 10,
        ),
        Text(text)
      ]));
}

class ButtonWidgetBackground extends StatelessWidget {
  const ButtonWidgetBackground({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDark = (App.themeNotifier.value == ThemeMode.dark);
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).canvasColor,
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        side: BorderSide(
            color: isDark ? Colors.white70 : Theme.of(context).primaryColor,
            width: 1),
      ),
      onPressed: () async {
        await UserPreferences.setBrightness(!isDark);
        App.themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;

        // Update the isDark variable after the theme mode has been updated.
        isDark = !isDark;
      },
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Icon(
          isDark ? LineAwesomeIcons.sun : LineAwesomeIcons.moon,
          color: isDark ? Colors.white70 : Theme.of(context).primaryColor,
          size: 24,
        ),
      ),
    );
  }
}

class ButtonWidgetShareProfile extends StatelessWidget {
  final VoidCallback onClicked;

  const ButtonWidgetShareProfile({Key? key, required this.onClicked})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDark = (App.themeNotifier.value == ThemeMode.dark);
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          foregroundColor: Colors.white,
          backgroundColor: Theme.of(context).canvasColor,
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          side: BorderSide(
              color: isDark ? Colors.white70 : Theme.of(context).primaryColor,
              width: 1),
        ),
        onPressed: onClicked,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Icon(
            LineAwesomeIcons.share_square,
            color: isDark ? Colors.white70 : Theme.of(context).primaryColor,
            size: 24,
          ),
        ));
  }
}

class ButtonWidgetLogOut extends StatelessWidget {
  final String text;
  final VoidCallback onClicked;

  const ButtonWidgetLogOut(
      {Key? key, required this.text, required this.onClicked})
      : super(key: key);

  @override
  Widget build(BuildContext context) => ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: const StadiumBorder(),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 22),
      ),
      onPressed: onClicked,
      child: Row(children: <Widget>[
        const Icon(
          LineAwesomeIcons.alternate_sign_out,
        ),
        const SizedBox(
          width: 10,
        ),
        Text(text)
      ]));
}

Future<void> storageReset() async{
  await UserPreferences.setForeName("NotLoggedInError");
  await UserPreferences.setMemPref(0);
  await UserPreferences.setCleanPref(0);
  await UserPreferences.setNoisePref(0);
  await UserPreferences.setNightPref(0);
  await UserPreferences.setAppsMax(2);
  await UserPreferences.setYearPref(0);
  await UserPreferences.setUni("NotLoggedInError");
}