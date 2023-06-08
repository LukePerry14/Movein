import 'package:flutter/material.dart';
import 'package:movein/navbar.dart';
import 'package:movein/HScroll.dart';
import 'package:movein/Pages/Messages.dart';
import 'package:movein/Pages/Groups.dart';
import 'package:movein/Pages/Settings.dart';
import 'package:movein/Pages/Houses.dart';
import 'package:movein/Pages/Profile.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class Scroller extends StatefulWidget {
  const Scroller({Key? key}) : super(key: key);

  @override
  State<Scroller> createState() => _ScrollerState();
}

class _ScrollerState extends State<Scroller> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Material(
        color: Colors.transparent,
        child: SafeArea(
          child: Scaffold(
            body: Container(
              alignment: Alignment.center,
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: 20.0,
                    alignment: Alignment.bottomCenter,
                    child: null,
                  ),
                  const Gscroller(),
                ],
              ),
            ),
            floatingActionButton: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  child: Icon(LineAwesomeIcons.angle_right),
                  backgroundColor: Colors.orange[300]?.withOpacity(0.5),
                  onPressed: () {},
                ),
                FloatingActionButton(
                  child: Icon(LineAwesomeIcons.times),
                  backgroundColor: Colors.orange[300]?.withOpacity(0.5),
                  onPressed: () {},
                ),
                FloatingActionButton(
                  child: Icon(LineAwesomeIcons.check),
                  backgroundColor: Colors.orange[300]?.withOpacity(0.5),
                  onPressed: () {},
                ),
              ],
            ),
            bottomNavigationBar: custom_navbar(),
          ),
        ),
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
