// ignore_for_file: camel_case_types
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movein/UserPreferences.dart';
import 'package:movein/navbar.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../main.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  // void _copyToClipboard(BuildContext context) {
  //   Clipboard.setData(const ClipboardData(text: 'iKxLSxcDqlT6vtHe71Bp'));
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text('Copied to clipboard', style: Theme.of(context).textTheme.bodySmall,),
  //       backgroundColor: Theme.of(context).primaryColor,
  //       duration: const Duration(seconds: 1),
  //     ),
  //   );
  // }

  @override
  State<Profile> createState() => _ProfilePage();
}

class _ProfilePage extends State<Profile> {
  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: 'iKxLSxcDqlT6vtHe71Bp'));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied to clipboard', style: Theme.of(context).textTheme.bodySmall,),
        backgroundColor: Theme.of(context).primaryColor,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  XFile? _image;
  final _picker = ImagePicker();

  Future<void> _openImagePicker() async {
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = pickedImage;
      // azure upload will go here
    });
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final navigator = Navigator.of(context);
      return Scaffold(
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: backgroundButton()),
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            print("testing");
                          },
                          child: Container(
                            width: 150, // Set a fixed width for the container
                            height: 150, // Set a fixed height for the container
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: const ClipOval(
                              child: Image(
                                image: AssetImage("assets/Pictures/dora.png"),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            height: 30.0,
                            width: 30.0,
                            decoration: BoxDecoration(
                              color: Colors.white60,
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.5),
                                width: 1, // Adjust the border width as needed
                              ),
                            ),
                            child: const Icon(LineAwesomeIcons.pen_nib,
                                color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: shareProfileButton(),
                    )
                  ],
                ),
                const SizedBox(height: 20.0),
                const Text("Name",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => _copyToClipboard(context),
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        child: const Text(
                          'iKxLSxcDqlT6vtHe71Bp',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _copyToClipboard(context),
                      child: const Icon(Icons.copy),
                    ),
                  ]
                ),
                const SizedBox(height: 50.0),
                upgradeAccountButton(),
                const SizedBox(height: 35.0),
                Divider(height: 1, color: Colors.grey.withOpacity(0.3),),
                const SizedBox(height: 35.0),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).primaryColor, width: 1),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Icon(LineAwesomeIcons.user, color: Theme.of(context).primaryColor),
                  ),
                  title: Text("Edit Profile", style: Theme.of(context).textTheme.headlineSmall,),
                  trailing: const Icon(LineAwesomeIcons.angle_right),
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
                      border: Border.all(color: Theme.of(context).primaryColor, width: 1),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Icon(LineAwesomeIcons.cog, color: Theme.of(context).primaryColor),
                  ),
                  title: Text("Settings", style: Theme.of(context).textTheme.headlineSmall,),
                  trailing: const Icon(LineAwesomeIcons.angle_right),
                  onTap: () {
                    Navigator.pushNamed(context, '/Settings');
                  }
                ),
                const SizedBox(height: 30),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red, width: 1),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Icon(LineAwesomeIcons.alternate_sign_out, color: Colors.red),
                  ),
                  title: Text("Log Out", style: GoogleFonts.lexend(color: Colors.red, fontWeight: FontWeight.normal, fontSize: 20.0)),
                  onTap: () => {
                    FirebaseAuth.instance.signOut(),
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/Auth', (route) => false)
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
  final VoidCallback onClicked;

  const ButtonWidgetBackground({Key? key, required this.onClicked})
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
      side: BorderSide(color: Theme.of(context).primaryColor, width: 1),
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
        color: Theme.of(context).primaryColor,
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
  Widget build(BuildContext context) => ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).canvasColor,
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        side: BorderSide(color: Theme.of(context).primaryColor, width: 1),
      ),
      onPressed: onClicked,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Icon(
          LineAwesomeIcons.share_square,
          color: Theme.of(context).primaryColor,
          size: 24,
        ),
      ));
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

Widget upgradeAccountButton() =>
    ButtonWidget(text: 'Upgrade Account', onClicked: () {});

Widget backgroundButton() => ButtonWidgetBackground(onClicked: () {});
Widget shareProfileButton() => ButtonWidgetShareProfile(onClicked: () {});

