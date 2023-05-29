import 'package:flutter/material.dart';
import 'package:movein/navbar.dart';
import 'package:movein/Pages/Scroller.dart';
import 'package:movein/Pages/Messages.dart';
import 'package:movein/Pages/Houses.dart';
import 'package:movein/Pages/Settings.dart';
import 'package:movein/Pages/Loading.dart';
import 'package:movein/Pages/Profile.dart';

class groups extends StatefulWidget {
  const groups({Key? key}) : super(key: key);

  @override
  State<groups> createState() => _groupsState();
}

class _groupsState extends State<groups> {

  @override
  void initState() {
    // TODO: call API to retrieve groups and group data
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Text('example Groups'),
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
