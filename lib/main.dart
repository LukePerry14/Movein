import 'package:flutter/material.dart';
import 'package:movein/Pages/Scroller.dart';
import 'package:movein/Themes/lMode.dart';
import 'package:movein/Pages/Groups.dart';
import 'package:movein/Pages/Houses.dart';
import 'package:movein/Pages/Messages.dart';
import 'package:movein/Pages/Profile.dart';
import 'package:movein/Pages/Settings.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: LAppTheme.lightTheme,
      darkTheme: LAppTheme.darkTheme,
      themeMode: ThemeMode.light,

      initialRoute: '/Scroller',

      routes: {
        '/Scroller': (context) => const Scroller(),
        '/Messages': (context) => const Messages(),
        '/Groups': (context) => const Groups(),
        '/Profile': (context) => const Profile(),
        '/Settings': (context) => const Settings(),
        '/Houses': (context) => const Houses(),
      },
    );
  }
}


