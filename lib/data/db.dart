import 'dart:io';
import 'dart:math' as math;
import 'package:path_provider/path_provider.dart';
import 'package:pvl/constants.dart';
import 'package:sqflite/sqflite.dart';
import '../model.dart';

Future<String?> getDbFile() async {
  Directory? dbDir;
  if (Platform.isIOS) {
    // dbDir = Directory(await getDatabasesPath());
  } else if (Platform.isAndroid) {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String rootPath = appDocDir.parent.path;
    dbDir = Directory('$rootPath/files/QML/OfflineStorage/Databases');
  }

  if (dbDir != null && dbDir.existsSync()) {
    List<FileSystemEntity> list = dbDir.listSync();
    for (var file in list) {
      if (file.path.endsWith('.sqlite')) {
        print('db file: ${file.path}');
        return file.path;
      }
    }
  } else {
    print('db is not found.');
  }
}

void removeDbFile() async {
  if (Platform.isAndroid) {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String rootPath = appDocDir.parent.path;
    Directory dbDir = Directory('$rootPath/files/QML/OfflineStorage/Databases');
    dbDir.delete(recursive: true);
  }
}

Future<List<Profile>> getProfileListFromDb(String path) async {
  List<Profile> profileList = [];

  Database db = await openDatabase(path);
  List<Map> list = await db.rawQuery('SELECT id, name, create_time, battery_options FROM profiles_new');
  for (var map in list) {
    if (map['id'] > 0) {
      int batteryOptionsId = map['battery_options'];
      List<Map> bss = await db.query('battery_settings',
        columns: ['system_voltage', 'battery_option', 'battery_custom_table'],
        where: 'id = ?',
        whereArgs: [batteryOptionsId],
      );
      if (bss.length > 0) {
        var bs = bss.first;
        int systemType = bs['system_voltage'];
        int batteryType = bs['battery_option'];
        int customId = bs['battery_custom_table'];
        BatteryOption? bo = await _getBatteryOption(db, batteryType, customId);
        if (bo != null) {
          Profile profile = Profile(title: map['name']);
          profile.summary = map['create_time'];
          bo.systemType = systemType;
          profile.batteryOption = bo;
          profileList.add(profile);
        }
      }
    }
  }
  await db.close();
  return profileList;
}

Future<BatteryOption?> _getBatteryOption(Database db, int batteryType, int customId) async {
  switch (batteryType) {
    case Constants.BATTERY_TYPE_SEALED:
      return Constants.batteryTypeSealed;
    case Constants.BATTERY_TYPE_COLLOID:
      return Constants.batteryTypeColloid;
    case Constants.BATTERY_TYPE_OPEN:
      return Constants.batteryTypeOpen;
    case Constants.BATTERY_TYPE_LIFOS:
      return Constants.batteryTypeLifos;
    case Constants.BATTERY_TYPE_CUSTOM:
      return await _getCustomBatteryOption(db, customId);
  }
}

Future<BatteryOption?> _getCustomBatteryOption(Database db, int customId) async {
  List<Map> list = await db.query('custom_battery_options',
    columns: ['equ_duration', 'bulk_duration', 'temp_coefficient', 'equ_voltage', 'bulk_voltage', 'bulk_return_voltage', 'float_voltage', 'lvd_voltage', 'lvd_resume_voltage'],
    where: 'id = ?',
    whereArgs: [customId],
  );
  if (list.length > 0) {
    Map map = list.first;
    double tc = map['temp_coefficient'];
    BatteryOption bo = BatteryOption(
      systemType: Constants.BATTERY_SYSTEM_TYPE_AUTO,
      batteryType: Constants.BATTERY_TYPE_CUSTOM,
      equDuration: map['equ_duration'],
      bulkDuration: map['bulk_duration'],
      tempCoefficient: tc.floor(),
      equVol: map['equ_voltage'],
      bulkVol: map['bulk_voltage'],
      floatVol: map['float_voltage'],
      bulkResumeVol: map['bulk_return_voltage'],
      lvdVol: map['lvd_voltage'],
      lvdResumeVol: map['lvd_resume_voltage'],
    );
    return bo;
  }
}