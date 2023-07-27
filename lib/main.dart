import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:movein/Pages/Scroller.dart';
import 'package:movein/Themes/lMode.dart';
import 'package:movein/Pages/Groups.dart';
import 'package:movein/Pages/Houses.dart';
import 'package:movein/Pages/Messages.dart';
import 'package:movein/Pages/Profile.dart';
import 'package:movein/Pages/Settings.dart';
import 'package:movein/Pages/profileInformation.dart';
import 'package:movein/Pages/GroupOptions.dart';
import 'package:movein/Pages/Friends.dart';
import 'package:movein/Pages/ScrollRefresh.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

var darkTheme = LAppTheme.darkTheme;
var lightTheme = LAppTheme.lightTheme;
enum ThemeType { Light, Dark }

class ThemeModel extends ChangeNotifier {
  ThemeData currentTheme = lightTheme;
  ThemeType _themeType = ThemeType.Dark;

  toggleTheme() {
    if (_themeType == ThemeType.Dark) {
      currentTheme = lightTheme;
      _themeType = ThemeType.Light;
    }
    else if (_themeType == ThemeType.Light) {
      currentTheme = darkTheme;
      _themeType = ThemeType.Dark;
    }
    return notifyListeners();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);  // Run the app
  // runApp(const App());
  runApp(
    ChangeNotifierProvider<ThemeModel>(
      create: (BuildContext context) => ThemeModel(),
      child: const App(),
    )
  );
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeModel>(context).currentTheme,
      // theme: LAppTheme.lightTheme,
      // darkTheme: LAppTheme.darkTheme,
      // themeMode: ThemeMode.light,

      initialRoute: '/Scroller',

      routes: {
        '/Scroller': (context) => const Scroller(),
        '/ScrollRefresh': (context) => const RanOut(),
        '/Messages': (context) => const Messages(),
        '/Groups': (context) => const Groups(),
        '/Profile': (context) => const Profile(),
        '/Settings': (context) => const Settings(),
        '/profileInformation': (context) => const profileInformation(),
        '/Friends': (context) => const Friends(),
        '/Houses': (context) => const Houses(),
        '/GroupOptions': (context) => const GroupOptions(),
      },
    );
  }
}


