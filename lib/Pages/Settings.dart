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
