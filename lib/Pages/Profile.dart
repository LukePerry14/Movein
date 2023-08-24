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
import 'package:movein/UserPreferences.dart';
import 'package:movein/navbar.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mime/mime.dart';
import 'package:http/http.dart' as http;
import 'package:azstore/azstore.dart' as AzureStorage;

import '../Auth code/auth.dart';
import '../Themes/lMode.dart';
import '../main.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);


  @override
  State<Profile> createState() => _ProfilePage();
}

class _ProfilePage extends State<Profile> {
  var data;
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
      String fullName = "$foreName $surname";

      return [fullName, profPic];
    } catch (e) {
      throw FirebaseException(
          message: 'Error retrieving name or profile picture: $e', plugin: 'cloud_firestore');
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

  // String blobURL = 'https://movein.blob.core.windows.net/moveinimages?sp=racwdli&st=2023-08-16T08:49:36Z&se=2024-04-17T16:49:36Z&sv=2022-11-02&sr=c&sig=odutsBXNqOBDLMkTdcqjIYSfBZMtZAxqFY%2Bw4OT9XM8%3D';
  // String SASToken = 'sp=racwdli&st=2023-08-16T08:49:36Z&se=2024-04-17T16:49:36Z&sv=2022-11-02&sr=c&sig=odutsBXNqOBDLMkTdcqjIYSfBZMtZAxqFY%2Bw4OT9XM8%3D';
  // New version
  Future<void> _uploadImageToAzure(File imageFile) async {
    Uint8List bytes = imageFile.readAsBytesSync();
    var x = AzureStorage.AzureStorage.parse('DefaultEndpointsProtocol=https;AccountName=movein;AccountKey=4MaJcz+DSy+KHInVIhTmtzj3OoWtTr0E+IDAjajCliKTaS5X5j3q2Rp69Q/oDiPtzGXfWw3OJPYh+ASt9PPo9w==;EndpointSuffix=core.windows.net');
    try {
      await x.putBlob('/moveinimages/userimage.jpg', contentType: 'image/jpg', bodyBytes: bytes);
    } catch (e) {
      print('Exception: $e');
    }
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
            return Builder(builder: (context) {
              final navigator = Navigator.of(context);
              bool isDark = App.themeNotifier.value == ThemeMode.dark;
              return Scaffold(
                body: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final pickedImage = await pickImage();
                            if (pickedImage != null) {
                              await _uploadImageToAzure(pickedImage);
                            }
                          },
                          child: Container(
                            width: 150, // Set a fixed width for the container
                            height: 150, // Set a fixed height for the container
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            ButtonWidgetShareProfile(onClicked: () {})
                          ],
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
                        onTap: () => showDialog(builder: (BuildContext context) => const AdvertisementDialog(), context: context),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(Radius.circular(42)),
                              boxShadow: [
                                BoxShadow(
                                  color: LAppTheme.lightTheme.primaryColor.withAlpha(200),
                                  offset: const Offset(0, 20),
                                  blurRadius: 30,
                                  spreadRadius: -5,
                                ),
                              ],
                              gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    LAppTheme.lightTheme.primaryColor.withAlpha(150),
                                    LAppTheme.lightTheme.primaryColor.withAlpha(200),
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
                            padding: EdgeInsets.symmetric(vertical: 15, horizontal: MediaQuery.of(context).size.width*0.125),
                            child: Text('upgrade'.tr, style: GoogleFonts.redHatDisplay(color: Colors.grey[100], fontSize: 16.5)),
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
                                  color: isDark? Colors.white70 : Theme.of(context).primaryColor,
                                  width: 1),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Icon(LineAwesomeIcons.user,
                                color: isDark? Colors.white70 : Theme.of(context).primaryColor),
                          ),
                          title: Text(
                            "edit_profile".tr,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          trailing: Icon(LineAwesomeIcons.angle_right, color: LAppTheme.lightTheme.primaryColor),
                          onTap: () {
                            Navigator.pushNamed(context, '/profileInformation');
                          },
                        ),
                        const SizedBox(height: 30.0),
                        ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: isDark? Colors.white70 : Theme.of(context).primaryColor,
                                    width: 1),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Icon(LineAwesomeIcons.cog,
                                  color: isDark? Colors.white70 : Theme.of(context).primaryColor),
                            ),
                            title: Text(
                              "settings".tr,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            trailing: Icon(LineAwesomeIcons.angle_right, color: LAppTheme.lightTheme.primaryColor),
                            onTap: () {
                              Navigator.pushNamed(context, '/Settings');
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
                          onTap: () async{
                            await UserPreferences.setForeName("NotLoggedInError");
                            FirebaseAuth.instance.signOut();
                            Navigator.pushNamedAndRemoveUntil(context, '/Login', (route) => false);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                bottomNavigationBar: CustomNavbar(
                  onItemSelected: (route) {
                    navigator.pushNamed(route);
                  },
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
      child: Text(text, style: Theme.of(context).textTheme.bodySmall,));
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

  const ButtonWidgetBackground({Key? key})
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
      side: BorderSide(color: isDark? Colors.white70 : Theme.of(context).primaryColor, width: 1),
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
        color: isDark? Colors.white70 : Theme.of(context).primaryColor,
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
          backgroundColor: Theme
              .of(context)
              .canvasColor,
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          side: BorderSide(color: isDark? Colors.white70 : Theme.of(context).primaryColor, width: 1),
        ),
        onPressed: onClicked,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Icon(
            LineAwesomeIcons.share_square,
            color: isDark? Colors.white70 : Theme.of(context).primaryColor,
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

