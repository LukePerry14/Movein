import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:movein/Pages/Scroller.dart';
import 'package:movein/Themes/lMode.dart';
import 'package:movein/Pages/Groups.dart';
import 'package:movein/Pages/Houses.dart';
import 'package:movein/Pages/Messages.dart';
import 'package:movein/Pages/Profile.dart';
import 'package:movein/Pages/SettingsPage.dart';
import 'package:movein/Pages/GroupOptions.dart';
import 'package:movein/Pages/Friends.dart';
import 'package:movein/Pages/profileInformation.dart';

void main() async {
  await Settings.init(cacheProvider: CustomCacheProvider());
  runApp(const App());
} 

class CustomCacheProvider extends CacheProvider {
  @override
  bool containsKey(String key, {String? defaultValue}) {
    return Settings.getValue(key);
  }

  @override
  bool? getBool(String key, {bool? defaultValue}) {
    return Settings.getValue(key, defaultValue: true);
  }

  @override
  double getDouble(String key, {double? defaultValue}) {
    return Settings.getValue(key);
  }

  @override
  int getInt(String key, {int? defaultValue}) {
    return Settings.getValue(key);
  }

  @override
  Set getKeys() {
    throw UnimplementedError();
  }

  @override
  String getString(String key, {String? defaultValue}) {
    return Settings.getValue(key);
  }

  @override
  T getValue<T>(String key, {T? defaultValue}) {
    return Settings.getValue(key);
  }

  @override
  Future<void> init() {
    return Settings.init();
  }

  @override
  Future<void> remove(String key, {Key? defaultValue}) {
    Settings.getValue(key, defaultValue: 'hello');
    throw UnimplementedError();
  }

  @override
  Future<void> removeAll() {
    // Needs to be done
    throw UnimplementedError();
  }

  @override
  Future<void> setBool(String key, bool? value) {
    return Settings.setValue(key, value);
  }

  @override
  Future<void> setDouble(String key, double? value) {
    return Settings.setValue(key, value);
  }

  @override
  Future<void> setInt(String key, int? value) {
    return Settings.setValue(key, value);
  }

  @override
  Future<void> setObject<T>(String key, T? value) {
    return Settings.setValue(key, value);
  }

  @override
  Future<void> setString(String key, String? value) {
    return Settings.setValue(key, value);
  }

}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: LAppTheme.lightTheme,
      darkTheme: LAppTheme.darkTheme,
      themeMode: ThemeMode.light,

      initialRoute: '/Scroller',

      routes: {
        '/Scroller': (context) => const Scroller(),
        '/Messages': (context) => const Messages(),
        '/Groups': (context) => const Groups(),
        '/Profile': (context) => const ProfilePage(),
        '/SettingsPage': (context) => const SettingsPage(),
        '/Friends': (context) => const Friends(),
        '/Houses': (context) => const Houses(),
        '/GroupOptions': (context) => const GroupOptions(),
        '/profileInformation': (context) => const ProfileInfo(),
      },
    );
  }
}


