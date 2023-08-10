import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static late SharedPreferences _preferences;

  static const _keyLocale = 'locale';
  static const _keyBrightness = 'brightness';

  static Future<SharedPreferences?> init() async {
    _preferences = await SharedPreferences.getInstance();
    print(_preferences.getString('userId'));
  }

  static Future setLocale(String locale) async =>
      await _preferences.setString(_keyLocale, locale);

  static String getLocale() => _preferences.getString(_keyLocale) ?? "en";

  static Future setBrightness(bool brightness) async =>
      await _preferences.setBool(_keyBrightness, brightness);

  static bool? getBrightness() => _preferences.getBool(_keyBrightness) ?? false;

  static String getUserId() => _preferences.getString("userId") ?? "";

  static Future setUserId(String userId) async =>
      await _preferences.setString("userId", userId);
}
