import 'package:flutter/material.dart';
import 'package:movein/navbar.dart';
import 'package:movein/Pages/Scroller.dart';
import 'package:movein/Pages/Groups.dart';
import 'package:movein/Pages/Settings.dart';
import 'package:movein/Pages/Houses.dart';
import 'package:movein/Pages/Loading.dart';
import 'package:movein/Pages/Profile.dart';

class messages extends StatefulWidget {
  const messages({Key? key}) : super(key: key);

  @override
  State<messages> createState() => _messagesState();
}

class _messagesState extends State<messages> {
  @override
  void initState() {
    // TODO: call API to retrieve message chains for account?
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Text('example Messages'),
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
