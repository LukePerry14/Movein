import 'package:flutter/material.dart';
import 'package:movein/Pages/Scroller.dart';
import 'package:movein/Pages/Messages.dart';
import 'package:movein/Pages/Groups.dart';
import 'package:movein/Pages/Settings.dart';
import 'package:movein/Pages/Houses.dart';
import 'package:movein/Pages/Loading.dart';
import 'package:movein/Pages/Profile.dart';

void main() {
  runApp(MaterialApp(
    initialRoute: '/Scroller',
    routes: {
      '/': (context) => Loading(),
      '/Scroller': (context) => Scroller(),
      '/Messages': (context) => Messages(),
      '/Groups': (context) => Groups(),
      '/Profile': (context) => Profile(),
      '/Settings': (context) => Settings(),
      '/Houses': (context) => Houses(),
    },
  ));
}


