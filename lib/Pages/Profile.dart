import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movein/navbar.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: 'iKxLSxcDqlT6vtHe71Bp'));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Copied to clipboard'),
        backgroundColor: Theme.of(context).primaryColor,
        duration: const Duration(seconds: 1),
      ),
    );
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
                          bottom: 5,
                          right: 20,
                          child: Container(
                            height: 30.0,
                            width: 30.0,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFCE14),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: const Icon(
                              LineAwesomeIcons.pen_nib,
                              color: Colors.white,
                            ),
                          ),
                        )
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
                const SizedBox(height: 30.0),
                upgradeAccountButton(),
                const SizedBox(height: 40.0),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      color: Theme.of(context).primaryColor),
                  child: ListTile(
                    onTap: () {
                      Navigator.pushNamed(context, '/profileInformation');
                    },
                    leading: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Icon(
                        LineAwesomeIcons.user,
                        color: Colors.white,
                      ),
                    ),
                    title: const Text("Profile information",
                        style: TextStyle(
                          color: Colors.white,
                        )),
                  ),
                ),
                const SizedBox(height: 30.0),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      color: Theme.of(context).primaryColor),
                  child: ListTile(
                    onTap: () {
                      Navigator.pushNamed(context, '/Settings');
                    },
                    leading: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.grey[200]?.withOpacity(0.1),
                      ),
                      child:
                          const Icon(LineAwesomeIcons.cog, color: Colors.white),
                    ),
                    title: const Text("Settings",
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      color: Theme.of(context).primaryColor),
                  child: ListTile(
                    onTap: () => {
                      FirebaseAuth.instance.signOut(),
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/Auth', (route) => false)
                    },
                    leading: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Icon(
                        LineAwesomeIcons.alternate_sign_out,
                        color: Colors.white,
                      ),
                    ),
                    title: const Text("Logout",
                        style: TextStyle(color: Colors.white)),
                  ),
                )
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
          foregroundColor: Colors.white),
      onPressed: onClicked,
      child: Text(text));
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
  Widget build(BuildContext context) => ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      ),
      onPressed: onClicked,
      child: const Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(5.0),
            child: Icon(
              LineAwesomeIcons.sun,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ));
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
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      ),
      onPressed: onClicked,
      child: const Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(5.0),
            child: Icon(
              LineAwesomeIcons.share_square,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
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
