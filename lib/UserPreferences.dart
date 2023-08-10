import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static late SharedPreferences _preferences;

  static const _keyUserId = 'userId';
  static const _keyLocale = 'locale';
  static const _keyBrightness = 'brightness';
  static const _keyAppsMax = 'AppsMax';

  static Future<SharedPreferences?> init() async => _preferences = await SharedPreferences.getInstance();

  static Future setAppsMax(String AppsMax)  async =>
      await _preferences.setString(_keyAppsMax, AppsMax);

  static int getAppsMax() => _preferences.getInt(_keyAppsMax) ?? 3;

  static Future setLocale(String locale)  async =>
      await _preferences.setString(_keyLocale, locale);

  static String getLocale() => _preferences.getString(_keyLocale) ?? "en";

  static Future setBrightness(bool brightness) async =>
      await _preferences.setBool(_keyBrightness, brightness);

  static bool? getBrightness() => _preferences.getBool(_keyBrightness) ?? false;
}
