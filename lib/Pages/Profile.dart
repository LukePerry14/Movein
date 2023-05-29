import 'package:flutter/material.dart';
import 'package:movein/navbar.dart';
import 'package:movein/Pages/Scroller.dart';
import 'package:movein/Pages/Messages.dart';
import 'package:movein/Pages/Groups.dart';
import 'package:movein/Pages/Settings.dart';
import 'package:movein/Pages/Houses.dart';
import 'package:movein/Pages/Loading.dart';

class profile extends StatefulWidget {
  const profile({Key? key}) : super(key: key);

  @override
  State<profile> createState() => _profileState();
}

class _profileState extends State<profile> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Text('example Profile'),
        ),

        bottomNavigationBar: custom_navbar(),
      ),
      routes: {
        '/Scroller': (context) => scroller(),
        '/Messages': (context) => messages(),
        '/Groups': (context) => groups(),
        '/Profile': (context) => profile(),
        '/Settings': (context) => settings(),
        '/Houses': (context) => houses(),
      },

    );
  }
}
