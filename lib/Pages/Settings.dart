import 'package:flutter/material.dart';
import 'package:movein/navbar.dart';
import 'package:movein/Pages/Scroller.dart';
import 'package:movein/Pages/Messages.dart';
import 'package:movein/Pages/Groups.dart';
import 'package:movein/Pages/Houses.dart';
import 'package:movein/Pages/Profile.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar( //maybe replace with a sliverappbar to improve polish
          backgroundColor: Colors.orange[300],
          title: const Text('Settings'),
          centerTitle: true,
          elevation: 0,
          leading: BackButton(
            color: Colors.grey[500],
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              color: Colors.grey[500],
              icon: Icon(Icons.more_vert), //Icon not showing
              onPressed: () {
                // Handle settings button press
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Text('example Settings'),
        ),
        bottomNavigationBar: custom_navbar(),
      ),
      routes: {
        '/Scroller': (context) => Scroller(),
        '/Messages': (context) => Messages(),
        '/Groups': (context) => Groups(),
        '/Profile': (context) => Profile(),
        '/Settings': (context) => Settings(),
        '/Houses': (context) => Houses(),
      },
    );
  }
}
