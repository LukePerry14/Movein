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
      '/': (context) => loading(),
      '/Scroller': (context) => scroller(),
      '/Messages': (context) => messages(),
      '/Groups': (context) => groups(),
      '/Profile': (context) => profile(),
      '/Settings': (context) => settings(),
      '/Houses': (context) => houses(),
    },
  ));
}


