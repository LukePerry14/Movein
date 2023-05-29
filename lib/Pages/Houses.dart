import 'package:flutter/material.dart';
import 'package:movein/navbar.dart';
import 'package:movein/Pages/Scroller.dart';
import 'package:movein/Pages/Messages.dart';
import 'package:movein/Pages/Groups.dart';
import 'package:movein/Pages/Settings.dart';
import 'package:movein/Pages/Loading.dart';
import 'package:movein/Pages/Profile.dart';

class houses extends StatefulWidget {
  const houses({Key? key}) : super(key: key);

  @override
  State<houses> createState() => _housesState();
}

class _housesState extends State<houses> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Text('example Houses'),
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
