import 'package:intl/intl.dart';
import 'model.dart';

class Constants {
  static const KEY_VERSION_0102 = 0x0102;

  static const BATTERY_SYSTEM_TYPE_AUTO = 0x00;
  static const BATTERY_SYSTEM_TYPE_12 = 0x01;
  static const BATTERY_SYSTEM_TYPE_24 = 0x02;

  static const BATTERY_TYPE_SEALED = 0x00;
  static const BATTERY_TYPE_COLLOID  = 0x01;
  static const BATTERY_TYPE_OPEN  = 0x02;
  static const BATTERY_TYPE_LIFOS  = 0x03;
  static const BATTERY_TYPE_CUSTOM = 0x08;

  static final datetimeFormat = DateFormat('yyyy-MM-dd hh:mm:ss');
  static final rebootWaitSeconds = 5;

  static Profile defaultProfile = Profile(
    title: 'Factory Reset Configuration',
    batteryOption: batteryTypeSealed
  );

  static BatteryOption batteryTypeSealed = BatteryOption(
    systemType: Constants.BATTERY_SYSTEM_TYPE_AUTO,
    batteryType: Constants.BATTERY_TYPE_SEALED,
    equDuration: 120,
    bulkDuration: 120,
    tempCoefficient: -3,
    equVol: 14.6,
    bulkVol: 14.4,
    floatVol: 13.8,
    bulkResumeVol: 13.2,
    lvdVol: 11.1,
    lvdResumeVol: 12.4,
  );
  static BatteryOption batteryTypeColloid = BatteryOption(
    systemType: Constants.BATTERY_SYSTEM_TYPE_AUTO,
    batteryType: Constants.BATTERY_TYPE_COLLOID,
    equDuration: 0,
    bulkDuration: 120,
    tempCoefficient: -3,
    equVol: 14.2,
    bulkVol: 14.2,
    floatVol: 13.8,
    bulkResumeVol: 13.2,
    lvdVol: 11.1,
    lvdResumeVol: 12.4,
  );
  static BatteryOption batteryTypeOpen = BatteryOption(
    systemType: Constants.BATTERY_SYSTEM_TYPE_AUTO,
    batteryType: Constants.BATTERY_TYPE_OPEN,
    equDuration: 120,
    bulkDuration: 120,
    tempCoefficient: -3,
    equVol: 14.8,
    bulkVol: 14.6,
    floatVol: 13.8,
    bulkResumeVol: 13.2,
    lvdVol: 11.1,
    lvdResumeVol: 12.4,
  );
  static BatteryOption batteryTypeLifos = BatteryOption(
    systemType: Constants.BATTERY_SYSTEM_TYPE_AUTO,
    batteryType: Constants.BATTERY_TYPE_LIFOS,
    equDuration: 120,
    bulkDuration: 250,
    tempCoefficient: -3,
    equVol: 14.6,
    bulkVol: 14.6,
    floatVol: 14.6,
    bulkResumeVol: 13.2,
    lvdVol: 11.1,
    lvdResumeVol: 12.4,
  );
  static BatteryOption batteryTypeCustom = BatteryOption(
    systemType: Constants.BATTERY_SYSTEM_TYPE_12,
    batteryType: Constants.BATTERY_TYPE_CUSTOM,
    equDuration: 120,
    bulkDuration: 120,
    tempCoefficient: -3,
    equVol: 14.6,
    bulkVol: 14.4,
    floatVol: 13.8,
    bulkResumeVol: 13.2,
    lvdVol: 11.1,
    lvdResumeVol: 12.4,
  );

  static const equDurationParam = Param(
    title: 'Equalization Duration',
    min: 0,
    max: 250,
    step: 1,
    decimals: 0,
    unit: 'Min'
  );

  static const equVoltageParam = Param(
      title: 'Equalization Voltage',
      min: 6,
      max: 80,
      step: 0.01,
      decimals: 2,
      unit: 'V'
  );

  static const bulkDurationParam = Param(
      title: 'Bulk Duration',
      min: 0,
      max: 250,
      step: 1,
      decimals: 0,
      unit: 'Min'
  );

  static const bulkVoltageParam = Param(
      title: 'Bulk Voltage',
      min: 6,
      max: 80,
      step: 0.01,
      decimals: 2,
      unit: 'V'
  );

  static const bulkReturnVoltageParam = Param(
      title: 'Bulk Return Voltage',
      min: 6,
      max: 80,
      step: 0.01,
      decimals: 2,
      unit: 'V'
  );

  static const floatVoltageParam = Param(
      title: 'Float Voltage',
      min: 6,
      max: 80,
      step: 0.01,
      decimals: 2,
      unit: 'V'
  );

  static const lowDisconnectVoltageParam = Param(
      title: 'Low Disconnect Voltage',
      min: 4,
      max: 80,
      step: 0.01,
      decimals: 2,
      unit: 'V'
  );

  static const lowResumeVoltageParam = Param(
      title: 'Low Resume Voltage',
      min: 4,
      max: 80,
      step: 0.01,
      decimals: 2,
      unit: 'V'
  );
}