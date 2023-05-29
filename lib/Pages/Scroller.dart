import 'package:flutter/material.dart';
import 'package:movein/navbar.dart';
import 'package:movein/Swiper.dart';
import 'package:movein/Pages/Messages.dart';
import 'package:movein/Pages/Groups.dart';
import 'package:movein/Pages/Settings.dart';
import 'package:movein/Pages/Houses.dart';
import 'package:movein/Pages/Loading.dart';
import 'package:movein/Pages/Profile.dart';

class scroller extends StatefulWidget {
  const scroller({Key? key}) : super(key: key);

  @override
  State<scroller> createState() => _scrollerState();
}

class _scrollerState extends State<scroller> {

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
                  const Swiper(),
                  Container(
                    height: 20.0,
                    alignment: Alignment.bottomCenter,
                    child: null,
                  ),
                ],
              ),
            ),

            bottomNavigationBar: custom_navbar(),
          ),

        ),

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

