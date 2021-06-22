import 'dart:typed_data';
import 'package:sprintf/sprintf.dart';
import '../model.dart';
import '../extensions.dart';
const privateKey = [0x40476491, 0x79520980, 0x11627080, 0x28559885];
const DELTA = 0x9e3779b9;
//MX (((z>>5^y<<2) + (y>>3^z<<4)) ^ ((sum^y) + (key[(p&3)^e] ^ z)))

int MX(int y, int z, int sum, int p, int e, List<int> key) {
  return (((z >> 5 ^ y << 2) + (y >> 3 ^ z << 4)) ^
      ((sum ^ y) + (key[(p & 3) ^ e] ^ z)));
}

void btea(List<int> v, int n, List<int> key) {
  int y, z, sum;
  int p, rounds, e;
  if (n > 1) {
    /* Coding Part */
    rounds = 6 + 52 ~/ n;
    sum = 0;
    z = v[n - 1];
    do {
      sum += DELTA;
      e = (sum >> 2) & 3;
      for (p = 0; p < n - 1; p++) {
        y = v[p + 1];
        z = v[p] += MX(y, z, sum, p, e, key);
      }
      y = v[0];
      z = v[n - 1] += MX(y, z, sum, p, e, key);
    } while (--rounds > 0);
  } else if (n < -1) {
    /* Decoding Part */
    n = -n;
    rounds = 6 + 52 ~/ n;
    sum = rounds * DELTA;
    y = v[0];
    do {
      e = (sum >> 2) & 3;
      for (p = n - 1; p > 0; p--) {
        z = v[p - 1];
        y = v[p] -= MX(y, z, sum, p, e, key);
      }
      z = v[n - 1];
      y = v[0] -= MX(y, z, sum, p, e, key);
      sum -= DELTA;
    } while (--rounds > 0);
  }
}

Uint8List int64bytes(int value) =>
    Uint8List(8)..buffer.asInt64List()[0] = value;

String hexString(List<int> list, {String label = ''}) {
  String result = '';
  for (var d in list) {
    String r = d.toRadixString(16);
    if (r.length == 1) {
      r = '0$r';
    }
    result += " ," + r;
  }
  if (result.isNotEmpty) {
    return '$label: ${result.substring(2)}';
  } else {
    return '$label: $result';
  }
}

class Protocol {
  static const SLIP_END = 0XC0;
  static const SLIP_ESC = 0XDB;
  static const SLIP_ESC_ESC = 0XDD;
  static const SLIP_ESC_END = 0XDC;

  static const FRAME_HEADER = 0XC0;
  static const FRAME_END = 0XC0;

  static const minLength = 4;

  static int crc16(List<int> value) {
    int tmp;
    int crc = 0xffff;
    for (int i = 0; i < value.length; i++) {
      tmp = value[i] & 0xFF;
      crc = crc ^ tmp;
      crc &= 0xFFFF;
      for (int j = 0; j < 8; j++) {
        if (crc & 0x1 > 0) {
          crc >>= 1;
          crc ^= 0xa001;
        } else {
          crc >>= 1;
        }
        crc &= 0xFFFF;
      }
    }
    return (crc);
  }

  static List<int> slipEsc(List<int> data) {
    var list = <int>[];
    for (var b in data) {
      switch (b) {
        case SLIP_END:
          list.add(SLIP_ESC);
          list.add(SLIP_ESC_END);
          break;
        case SLIP_ESC:
          list.add(SLIP_ESC);
          list.add(SLIP_ESC_ESC);
          break;
        default:
          list.add(b);
          break;
      }
    }
    return list;
  }

  static List<int> slipUnesc(List<int> data) {
    var list = <int>[];
    for (int i = 0; i < data.length; i++) {
      int b = data[i];
      switch (b) {
        case SLIP_END:
          break;
        case SLIP_ESC:
          if (i == data.length - 1) {
            print("slipUnwrap error, last byte is SLIP_ESC");
            break;
          }
          int c = data[++i];
          if (c == SLIP_ESC_END) {
            list.add(SLIP_END);
          } else if (c == SLIP_ESC_ESC) {
            list.add(SLIP_ESC);
          }
          break;
        default:
          list.add(b);
          break;
      }
    }
    return list;
  }

  static List<int> slipFrame(List<int> data) {
    var crcData = data + [0x00, 0x00];
    int crc = crc16(data);
    crcData[data.length] = (crc >> 8) & 0xFF;
    crcData[data.length + 1] = crc & 0xFF;
    var slipCrcData = slipEsc(crcData);
    var frame = [FRAME_HEADER] + slipCrcData + [FRAME_END];
    return frame;
  }

  static parseDeviceStatus(List<int> data, DeviceStatus deviceStatus) {
    var dataIndex = 2;
    deviceStatus.runningTime = data[dataIndex++] << 24;
    deviceStatus.runningTime += data[dataIndex++] << 16;
    deviceStatus.runningTime += data[dataIndex++] << 8;
    deviceStatus.runningTime += data[dataIndex++];

    deviceStatus.battery1Level = data[dataIndex++];
    deviceStatus.battery2Level = data[dataIndex++];

    var pvVol = data[dataIndex++] << 8;
    pvVol += data[dataIndex++];
    deviceStatus.pvVol = pvVol / 100.0;

    var chargeCurrent = data[dataIndex++] << 8;
    chargeCurrent += data[dataIndex++];
    deviceStatus.chargeCurrent = chargeCurrent / 100.0;

    var chargeDuty = data[dataIndex++];
    deviceStatus.chargeDuty = chargeDuty;

    var batteryVol1 = data[dataIndex++] << 8;
    batteryVol1 += data[dataIndex++];
    deviceStatus.battery1Vol = batteryVol1 / 100.0;

    var batteryCurrent1 = data[dataIndex++] << 8;
    batteryCurrent1 += data[dataIndex++];
    deviceStatus.battery1ChargeCurrent = batteryCurrent1 / 100.0;

    deviceStatus.battery1ChargeMode = data[dataIndex++];
    deviceStatus.battery1ChargeEnabled = data[dataIndex++] == 1;

    var batteryVol2 = data[dataIndex++] << 8;
    batteryVol2 += data[dataIndex++];
    deviceStatus.battery2Vol = batteryVol2 / 100.0;

    var batteryCurrent2 = data[dataIndex++] << 8;
    batteryCurrent2 += data[dataIndex++];
    deviceStatus.battery2ChargeCurrent = batteryCurrent2 / 100.0;

    deviceStatus.battery2ChargeMode = data[dataIndex++];
    deviceStatus.battery2ChargeEnabled = data[dataIndex++] == 1;

    var currentBateryVol = deviceStatus.battery1ChargeEnabled
        ? deviceStatus.battery1Vol
        : deviceStatus.battery2Vol;
    if ((deviceStatus.pvVol - currentBateryVol) > 0.5) {
      deviceStatus.pvAvailible = true;
    } else {
      deviceStatus.pvAvailible = false;
    }
    if (deviceStatus.battery1Vol == 0) {
      deviceStatus.battery1Level = 0;
    }
    if (deviceStatus.battery2Vol == 0) {
      deviceStatus.battery2Level = 0;
    }
    deviceStatus.notify();
  }

  static parseChargeHist(List<int> frameData, EventLog eventLog) {
    var dataIndex = 2;

    var deviceTime = 0;
    deviceTime = frameData[dataIndex++] << 24;
    deviceTime = deviceTime + (frameData[dataIndex++] << 16);
    deviceTime = deviceTime + (frameData[dataIndex++] << 8);
    deviceTime = deviceTime + frameData[dataIndex++];
    eventLog.deviceTime = deviceTime;

    eventLog.battery1Level = frameData[dataIndex++];
    eventLog.battery2Level = frameData[dataIndex++];

    eventLog.logCount = frameData[dataIndex++];
    eventLog.events.clear();
    for (var i = 0; i < eventLog.logCount; i++) {
      var eventLogItem = new EventLogItem();

      var logTime = frameData[dataIndex++] << 24;
      logTime = logTime + (frameData[dataIndex++] << 16);
      logTime = logTime + (frameData[dataIndex++] << 8);
      logTime = logTime + frameData[dataIndex++];
      eventLogItem.time = logTime;

      eventLogItem.eventCatalog = frameData[dataIndex++];

      var batteryVol1 = (frameData[dataIndex++] << 8);
      batteryVol1 = batteryVol1 + frameData[dataIndex++];
      eventLogItem.battery1Vol = batteryVol1 / 100.0;

      var batteryVol2 = (frameData[dataIndex++] << 8);
      batteryVol2 = batteryVol2 + frameData[dataIndex++];
      eventLogItem.battery2Vol = batteryVol2 / 100.0;
      eventLog.events.add(eventLogItem);
    }

    eventLog.notify();
  }

  static parseDeviceInfo(List<int> frameData, SystemInfo sysInfo) {
    var dataIndex = 2;

    var deviceTime = frameData[dataIndex++] << 24;
    deviceTime = deviceTime + (frameData[dataIndex++] << 16);
    deviceTime = deviceTime + (frameData[dataIndex++] << 8);
    deviceTime = deviceTime + frameData[dataIndex++];

    sysInfo.deviceTime = deviceTime;
    sysInfo.battery1Level = frameData[dataIndex++];
    sysInfo.battery2Level = frameData[dataIndex++];

    var hwPlatform = String.fromCharCode(frameData[dataIndex++]);
    hwPlatform += String.fromCharCode(frameData[dataIndex++]);
    hwPlatform += String.fromCharCode(frameData[dataIndex++]);
    hwPlatform += String.fromCharCode(frameData[dataIndex++]);
    hwPlatform += String.fromCharCode(frameData[dataIndex++]);
    hwPlatform += String.fromCharCode(frameData[dataIndex++]);
    hwPlatform += String.fromCharCode(frameData[dataIndex++]);
    hwPlatform += String.fromCharCode(frameData[dataIndex++]);
    sysInfo.hwPlatform = hwPlatform;

    var modal = String.fromCharCode(frameData[dataIndex++]); //modal string 0
    modal += String.fromCharCode(frameData[dataIndex++]);
    modal += String.fromCharCode(frameData[dataIndex++]);
    modal += String.fromCharCode(frameData[dataIndex++]);
    modal += String.fromCharCode(frameData[dataIndex++]);
    modal += String.fromCharCode(frameData[dataIndex++]);
    modal += String.fromCharCode(frameData[dataIndex++]);
    modal += String.fromCharCode(frameData[dataIndex++]);
    modal += String.fromCharCode(frameData[dataIndex++]);
    sysInfo.modal = modal;
    sysInfo.hardwareVersion =
        '${frameData[dataIndex++]}.${frameData[dataIndex++]}';
    sysInfo.softwareVersion =
        '${frameData[dataIndex++]}.${frameData[dataIndex++]}';

    var unique0 = sprintf("%02x", [frameData[dataIndex++]]);
    var unique1 = sprintf("%02x", [frameData[dataIndex++]]);
    var unique2 = sprintf("%02x", [frameData[dataIndex++]]);
    var unique3 = sprintf("%02x", [frameData[dataIndex++]]);

    sysInfo.uniqueID = unique3 + ":" + unique2 + ":" + unique1 + ":" + unique0;
    sysInfo.manufactureCode = frameData[dataIndex++];
    sysInfo.notify();
  }

  static parseBatteryOptions(List<int> frameData, BatteryOption batteryOption) {
    var rawData = frameData.sublist(2);

    var dataIndex = 0;
    var batterySystemType = (rawData[dataIndex] >> 4) & 0x0F;
    var batteryType = (rawData[dataIndex] & 0x0F);

    var equDuration = (rawData[++dataIndex] << 8);
    equDuration += (rawData[++dataIndex]);

    var bulkDuration = (rawData[++dataIndex] << 8);
    bulkDuration += (rawData[++dataIndex]);

    var tempCoefficient = rawData[++dataIndex];

    var ovdVol = (rawData[++dataIndex] << 8);
    ovdVol += (rawData[++dataIndex]);

    var equVol = (rawData[++dataIndex] << 8);
    equVol += (rawData[++dataIndex]);

    var bulkVol = (rawData[++dataIndex] << 8);
    bulkVol += (rawData[++dataIndex]);

    var bulkResumeVol = (rawData[++dataIndex] << 8);
    bulkResumeVol += (rawData[++dataIndex]);

    var floatVol = (rawData[++dataIndex] << 8);
    floatVol += (rawData[++dataIndex]);

    var lvdVol = (rawData[++dataIndex] << 8);
    lvdVol += (rawData[++dataIndex]);

    var lvdResumeVol = (rawData[++dataIndex] << 8);
    lvdResumeVol += (rawData[++dataIndex]);

    var lowWarningVol = (rawData[++dataIndex] << 8);
    lowWarningVol += (rawData[++dataIndex]);

    var lowWarningResumeVol = (rawData[++dataIndex] << 8);
    lowWarningResumeVol += (rawData[++dataIndex]);

    if (((tempCoefficient >> 7) & 0x01) > 0) //tempCoefficient is a minus number
    {
      tempCoefficient = ((~(tempCoefficient - 1)) & 0xFF) * -1;
    }

    batteryOption.systemType = batterySystemType;
    batteryOption.batteryType = batteryType;
    batteryOption.equDuration = equDuration;
    batteryOption.bulkDuration = bulkDuration;
    batteryOption.tempCoefficient = tempCoefficient;
    // batteryOption.ovdVol = ovdVol/100.0;
    batteryOption.equVol = equVol / 100.0;
    batteryOption.bulkVol = bulkVol / 100.0;
    batteryOption.bulkResumeVol = bulkResumeVol / 100.0;
    batteryOption.floatVol = floatVol / 100.0;
    batteryOption.lvdVol = lvdVol / 100.0;
    batteryOption.lvdResumeVol = lvdResumeVol / 100.0;
    batteryOption.lowWarningVol = lowWarningVol / 100.0;
    batteryOption.lowWarningResumeVol = lowWarningResumeVol / 100.0;

    batteryOption.notify();
  }

  static List<int> toRawData(BatteryOption batteryOption) {
    final divides = 1;
    final rawData = List.filled(18, 0);
    final equDuration = batteryOption.equDuration;
    final bulkDuration = batteryOption.bulkDuration;
    final tempCoefficient = batteryOption.tempCoefficient;
    final equVol = batteryOption.equVol.toPrecision(2) * 100 ~/ divides;
    final bulkVol = batteryOption.bulkVol.toPrecision(2) * 100 ~/ divides;
    final bulkResumeVol = batteryOption.bulkResumeVol.toPrecision(2) * 100 ~/ divides;
    final floatVol = batteryOption.floatVol.toPrecision(2) * 100 ~/ divides;
    final lvdVol = batteryOption.lvdVol.toPrecision(2) * 100 ~/ divides;
    final lvdResumeVol = batteryOption.lvdResumeVol.toPrecision(2) * 100 ~/ divides;
    rawData[0] = (batteryOption.systemType << 4) + batteryOption.batteryType;
    rawData[1] = (equDuration >> 8) & 0xFF;
    rawData[2] = (equDuration & 0xFF);

    rawData[3] = (bulkDuration >> 8) & 0xFF;
    rawData[4] = (bulkDuration & 0xFF);

    rawData[5] = (tempCoefficient & 0xFF);

    rawData[6] = (equVol >> 8) & 0xFF;
    rawData[7] = (equVol & 0xFF);

    rawData[8] = (bulkVol >> 8) & 0xFF;
    rawData[9] = (bulkVol & 0xFF);

    rawData[10] = (bulkResumeVol >> 8) & 0xFF;
    rawData[11] = (bulkResumeVol & 0xFF);

    rawData[12] = (floatVol >> 8) & 0xFF;
    rawData[13] = (floatVol & 0xFF);

    rawData[14] = (lvdVol >> 8) & 0xFF;
    rawData[15] = (lvdVol & 0xFF);

    rawData[16] = (lvdResumeVol >> 8) & 0xFF;
    rawData[17] = (lvdResumeVol & 0xFF);
    return rawData;
  }
}
