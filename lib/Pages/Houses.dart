import 'package:flutter/material.dart';
import 'package:movein/navbar.dart';
import 'package:movein/Pages/Scroller.dart';
import 'package:movein/Pages/Messages.dart';
import 'package:movein/Pages/Groups.dart';
import 'package:movein/Pages/Settings.dart';
import 'package:movein/Pages/Profile.dart';

class Houses extends StatefulWidget {
  const Houses({Key? key}) : super(key: key);

  @override
  State<Houses> createState() => _HousesState();
}

class _HousesState extends State<Houses> {
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
