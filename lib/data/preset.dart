import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model.dart';
import '../constants.dart';

class Preset {
  static Preset _instance = new Preset._();
  static Preset get instance => _instance;

  Preset._();

  static init() async {
    await _initSystemTimestamp();
  }

  static _initSystemTimestamp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? timestamp = prefs.getInt('init_system_timestamp');
    if (timestamp == null) {
      timestamp = DateTime.now().millisecondsSinceEpoch;
      prefs.setInt('init_system_timestamp', timestamp);
    }
    Constants.defaultProfile.timestamp = timestamp;
    Constants.defaultProfile.summary = Constants.datetimeFormat.format(DateTime.fromMillisecondsSinceEpoch(timestamp));
  }

  static Future<int> getInitSystemTimestamp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('init_system_timestamp') ?? 0;
  }

  static Future<bool?> isInitDataFromDb() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('init_data_from_db');
  }

  static Future<void> setInitDataFromDb(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('init_data_from_db', value);
  }

  static setLanguageCode(String languageCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString('language_code', languageCode);
  }

  static Future<String?> getLanguageCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('language_code');
  }

  static saveVoltageType(int voltageType) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('voltage_type', voltageType);
  }

  static Future<int> getVoltageType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('voltage_type') ?? Constants.BATTERY_SYSTEM_TYPE_AUTO;
  }

  static saveBatteryType(int batteryType) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('battery_type', batteryType);
  }

  static Future<int> getBatteryType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('battery_type') ?? Constants.BATTERY_TYPE_SEALED;
  }

  static saveCurrentBatteryOptions(BatteryOption batteryOption) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_battery_options', batteryOption.toJson());
  }

  static saveCustomBatteryOptions(BatteryOption batteryOption) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('custom_battery_options', batteryOption.toJson());
  }

  static Future<BatteryOption> getCustomBatteryOptions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var json = prefs.getString('custom_battery_options') ?? '';
    // print('json: $json');
    BatteryOption batteryOption;
    if (json.isNotEmpty) {
      batteryOption = BatteryOption.fromMap(jsonDecode(json));
      batteryOption.batteryType = Constants.BATTERY_TYPE_CUSTOM;
    } else {
      batteryOption = BatteryOption.copyFrom(Constants.batteryTypeCustom);
    }
    return batteryOption;
  }

  static void saveRememberPassword(String id, bool remember) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remember_password_$id', remember);
  }

  static Future<bool> isRememberPassword(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('remember_password_$id') ?? false;
  }

  static void savePassword(String id, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('password_$id', password);
  }

  static Future<String> getPassword(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('password_$id') ?? '';
  }

  static Future<List<Profile>> getProfiles() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String json = prefs.getString('profiles') ?? '';
    // print('read json:$json');
    List<Profile> list = <Profile>[];
    if (json.isNotEmpty) {
      var tempList = jsonDecode(json) as List;
      list = tempList.map((ts) {
        return Profile.fromMap(jsonDecode(ts));
      }).toList();
    }
    list = [Constants.defaultProfile] + list;
    return list;
  }

  static Future<void> saveProfiles(List<Profile> list) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (list.length <= 1) {
      prefs.remove('profiles');
    } else {
      var subList = list.sublist(1);
      var json = jsonEncode(subList.map((e) => e.toJson()).toList());
      // print('write json:$json');
      prefs.setString('profiles', json);
    }
  }
}