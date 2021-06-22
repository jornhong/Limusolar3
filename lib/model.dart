import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'constants.dart';

class BleSession with ChangeNotifier {
  int time = 0;
  int rxBytes = 0;
  int rxFrames = 0;
  int rxErrors = 0;
  int txBytes = 0;
  int txFrames = 0;
  int txErrors = 0;

  void incRxBytes(int length) {
    rxBytes += length;
    notifyListeners();
  }

  void incRxFrames(int length) {
    rxFrames += length;
    notifyListeners();
  }

  void incRxErrors(int length) {
    rxErrors += length;
    notifyListeners();
  }

  void incTxBytes(int length) {
    txBytes += length;
    notifyListeners();
  }

  void incTxFrames(int length) {
    txFrames += length;
    notifyListeners();
  }

  void incTxErrors(int length) {
    txErrors += length;
    notifyListeners();
  }

  void clear() {
    time = 0;
    rxBytes = 0;
    rxFrames = 0;
    rxErrors = 0;
    txBytes = 0;
    txFrames = 0;
    txErrors = 0;
    notify();
  }

  void notify() {
    notifyListeners();
  }

  static final dayFormat = DateFormat('dd Day HH:mm:ss');
  static final timeFormat = DateFormat('HH:mm:ss');
  String formatMSecToTimeFormat(int msecs) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(msecs).toUtc();
    if(msecs >= (24 * 3600 * 1000)) {
      return dayFormat.format(dateTime);
    }
    return timeFormat.format(dateTime);
  }
}

class DeviceStatus with ChangeNotifier {
  var runningTime = 0;
  var battery1Level = 0;
  var battery2Level = 0;
  var pvVol = 0.0;
  var chargeCurrent = 0.0;
  var chargeDuty = 0;
  var battery1Vol = 0.0;
  var battery2Vol = 0.0;
  var pvAvailible = false;
  var battery1ChargeCurrent = 0.0;
  var battery2ChargeCurrent = 0.0;
  var battery1ChargeMode = 0;
  var battery1ChargeEnabled = false;
  var battery2ChargeMode = 0;
  var battery2ChargeEnabled = false;

  static String chargeModeText(int chargeMode) {
    String text;
    switch(chargeMode) {
      case 0:
        text = "EQU";
        break;
      case 1:
        text = "BULK";
        break;
      case 2:
        text = "FLOAT";
        break;
      default:
        text = "OFF";
        break;
    }
    return text;
  }

  void notify() {
    notifyListeners();
  }
}

class SystemInfo with ChangeNotifier {
  var deviceTime = 0;
  var battery1Level = 0;
  var battery2Level = 0;
  var hwPlatform = "";
  var modal = "";
  var hardwareVersion = "";
  var softwareVersion = "";
  var uniqueID = "";
  var manufactureCode = 0;

  void notify() {
    notifyListeners();
  }
}

class EventLogItem with ChangeNotifier {
  var time = 0;
  var eventCatalog = 0;
  var battery1Vol = 0.0;
  var battery2Vol = 0.0;

  String get eventCatalogName {
    switch(eventCatalog) {
      case 0x00:
        return 'Close Charge';
      case 0x01:
        return 'Start Charge';
      default:
        return 'Unknown Event';
    }
  }

  void notify() {
    notifyListeners();
  }
}

class EventLog with ChangeNotifier {
  var deviceTime = 0;
  var battery1Level = 0;
  var battery2Level = 0;
  var logCount = 0;
  var events = <EventLogItem>[];
  void notify() {
    notifyListeners();
  }
}

class BatteryOption with ChangeNotifier {
  var valid = 0;
  var systemType = 0;
  var batteryType = 0; //12,24,48 system battery voltae
  var ovdVol = 0;
  var equDuration = 0;
  var bulkDuration = 0;
  var tempCoefficient = 0;
  var equVol = 0.0;
  var bulkVol = 0.0;
  var bulkResumeVol = 0.0;
  var floatVol = 0.0;
  var lvdVol = 0.0;
  var lvdResumeVol = 0.0;
  var lowWarningVol = 0.0;
  var lowWarningResumeVol = 0.0;

  BatteryOption({
    required this.systemType,
    required this.batteryType,
    required this.equDuration,
    required this.bulkDuration,
    required this.tempCoefficient,
    required this.equVol,
    required this.bulkVol,
    required this.bulkResumeVol,
    required this.floatVol,
    required this.lvdVol,
    required this.lvdResumeVol,
  });

  BatteryOption.copyFrom(BatteryOption batteryOption) {
    copyFrom(batteryOption);
  }

  void copyFrom(BatteryOption batteryOption) {
    valid = batteryOption.valid;
    systemType = batteryOption.systemType;
    batteryType = batteryOption.batteryType;
    copyParam(batteryOption);
  }

  void copyParam(BatteryOption batteryOption) {
    ovdVol = batteryOption.ovdVol;
    equDuration = batteryOption.equDuration;
    bulkDuration = batteryOption.bulkDuration;
    tempCoefficient = batteryOption.tempCoefficient;
    equVol = batteryOption.equVol;
    bulkVol = batteryOption.bulkVol;
    bulkResumeVol = batteryOption.bulkResumeVol;
    floatVol = batteryOption.floatVol;
    lvdVol = batteryOption.lvdVol;
    lvdResumeVol = batteryOption.lvdResumeVol;
    lowWarningVol = batteryOption.lowWarningVol;
    lowWarningResumeVol = batteryOption.lowWarningResumeVol;
  }

  BatteryOption.fromMap(Map<String, dynamic> json) {
    valid = json['valid'];
    systemType = json['systemType'];
    batteryType = json['batteryType'];
    ovdVol = json['ovdVol'];
    equDuration = json['equDuration'];
    bulkDuration = json['bulkDuration'];
    tempCoefficient = json['tempCoefficient'];
    equVol = json['equVol'];
    bulkVol = json['bulkVol'];
    bulkResumeVol = json['bulkResumeVol'];
    floatVol = json['floatVol'];
    lvdVol = json['lvdVol'];
    lvdResumeVol = json['lvdResumeVol'];
    lowWarningVol = json['lowWarningVol'];
    lowWarningResumeVol = json['lowWarningResumeVol'];
  }

  Map<String, dynamic> toMap() {
    return {
      'valid': valid,
      'systemType': systemType,
      'batteryType': batteryType,
      'ovdVol': ovdVol,
      'equDuration': equDuration,
      'bulkDuration': bulkDuration,
      'tempCoefficient': tempCoefficient,
      'equVol': equVol,
      'bulkVol': bulkVol,
      'bulkResumeVol': bulkResumeVol,
      'floatVol': floatVol,
      'lvdVol': lvdVol,
      'lvdResumeVol': lvdResumeVol,
      'lowWarningVol': lowWarningVol,
      'lowWarningResumeVol': lowWarningResumeVol,
    };
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  void notify() {
    notifyListeners();
  }
}

class Profile {
  String title = '';
  String summary = '';
  BatteryOption? batteryOption;
  int timestamp = 0;

  Profile({
    required this.title,
    this.batteryOption,
  });

  Profile.widthOptionAndTime(this.batteryOption, DateTime dateTime) {
    timestamp = dateTime.millisecondsSinceEpoch;
    summary = Constants.datetimeFormat.format(dateTime);
  }

  Profile.fromMap(Map<String, dynamic> map) {
    title = map['title'];
    summary = map['summary'];
    if (map['text'] != null) {
      batteryOption = BatteryOption.fromMap(jsonDecode(map['text']));
    }
    timestamp = map['timestamp'];
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'summary': summary,
      'text': batteryOption?.toJson(),
      'timestamp': timestamp,
    };
  }

  String toJson() {
    return jsonEncode(toMap());
  }
}

class Param {
  final String title;
  final double min;
  final double max;
  final double step;
  final int decimals;
  final String? unit;

  const Param({
    required this.title,
    this.min = 0,
    this.max = 100,
    this.step = 1,
    this.decimals = 0,
    this.unit
  });
}