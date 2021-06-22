import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pvl/generated/l10n.dart';
import '../ble.dart';
import 'dialog/common.dart';
import 'dialog/auth.dart';
import 'dialog/session.dart';
import 'dialog/scan.dart';
import '../constants.dart';

const methodChannel = const MethodChannel('com.flutter.io/bluetooth');
StreamSubscription<BluetoothState>? _stateSubscription;

Future<dynamic> _invokedMethods(MethodCall methodCall) async {
  switch (methodCall.method) {
    case 'enableBtResult':
      _stateSubscription?.cancel();
      print('enableBtResult');
      break;
  }
}

Future<bool?> _enableBluetooth() async {
  methodChannel.setMethodCallHandler(_invokedMethods);
  try {
    return await methodChannel.invokeMethod('enableBluetooth');
  } on PlatformException catch (e) {
    print(e);
  }
}

void blueIconClick(BuildContext context) async {
  if (Ble.instance.currentDeviceState == DeviceState.authorized) {
    showSessionDialog(context);
    return;
  }

  BluetoothDevice? device = await Ble.instance.connectedDevice;
  print('connected device: ${device?.name}');
  await device?.disconnect();
  await _stateSubscription?.cancel();
  if (Ble.instance.bluetoothState == BluetoothState.on) {
    startScan(context);
  } else if (Ble.instance.bluetoothState == BluetoothState.off) {
    if (Platform.isAndroid) {
      var ret = await showConfirmDialog(context, S
          .of(context)
          .Tips, S
          .of(context)
          .Bluetooth_is_disabled_enable_now,
      );
      if (ret == true) {
        _stateSubscription = Ble.instance.state.listen((state) async {
          print('state: $state');
          if(state == BluetoothState.on) {
            _stateSubscription?.cancel();
            startScan(context);
          } else if(state == BluetoothState.off) {
            _stateSubscription?.cancel();
          }
        });
        await _enableBluetooth();
      }
    } else {
      showAlertDialog(context, S
          .of(context)
          .Tips, S
          .of(context)
          .Bluetooth_is_not_enabled);
    }
  }
}

Future<void> startScan(BuildContext context) async {
  if (await Permission.location.request().isGranted) {
    _showDevicesDialog(context);
    Ble.instance.startScan();
  } else {
    var ret = await showConfirmDialog(context, S
        .of(context)
        .Tips, S
        .of(context)
        .Bluetooth_is_disabled_enable_now,);
    if (ret == true) {
      openAppSettings();
    }
  }
}

_showDevicesDialog(BuildContext context) async {
  var device = await showScanDialog(context);

  await Ble.instance.stopScan();
  if (device == null) {
    return;
  }

  _connectDevice(context, device);
}

void _connectDevice(BuildContext context, BluetoothDevice device) {
  var ss;
  bool isShowProcessing = false;
  ss = Ble.instance.deviceState.listen((state) async {
    print('state: $state');
    switch(state) {
      case DeviceState.disconnected:
        ss.cancel();
        if (isShowProcessing) {
          isShowProcessing = false;
          dismissProcessingDialog(context);
        }
        if (Ble.instance.prevDeviceState != DeviceState.disconnected
            && Ble.instance.prevDeviceState != DeviceState.needAuth
            && Ble.instance.prevDeviceState != DeviceState.authFailed) {
          showAlertDialog(context, device.name, S.of(context).Connect_Failed);
        }
        break;
      case DeviceState.bleConnecting:
      case DeviceState.bleConnected:
        if (!isShowProcessing) {
          showProcessingDialog(context, device.name, S
              .of(context)
              .Connecting);
          isShowProcessing = true;
        }
        break;
      case DeviceState.handshakeFailed:
        Ble.instance.disconnect();
        break;
      case DeviceState.needAuth:
        if (isShowProcessing) {
          isShowProcessing = false;
          dismissProcessingDialog(context);
        }
        var password = await showAuthDialog(context, '${S.of(context).Access} ${device.name}', device.id.id);
        if (password == null) {
          Ble.instance.disconnect();
        } else {
          Ble.instance.sendAuthorizion(password);
        }
        break;
      case DeviceState.authorized:
        ss.cancel();
        if (isShowProcessing) {
          isShowProcessing = false;
          dismissProcessingDialog(context);
        }
        Fluttertoast.showToast(
            msg: S.of(context).Device_Connected
        );
        break;
      case DeviceState.authFailed:
        Ble.instance.disconnect();
        showAlertDialog(context, '', S.of(context).Authentication_Failed);
        break;
      default:
        break;
    }
  });
  Ble.instance.connect(device);
}

void reconnect(BuildContext context, {int waitSeconds = 2}) async {
  if (Ble.instance.currentDevice == null) {
    print('Ble.instance.currentDevice is null');
    return;
  }
  print('reconnect');
  bool isProcessingShow = false;
  Timer? timer;
  if (Ble.instance.isConnected) {
    late StreamSubscription<DeviceState> subscription;
    subscription = Ble.instance.deviceState.listen((event) async {
      if (event == DeviceState.disconnected) {//waiting for disconnect
        print('disconnected, ready to connect');
        await subscription.cancel();
        await Ble.instance.disconnect();
        timer = Timer(Duration(seconds: waitSeconds), () {
          if (isProcessingShow) {
            isProcessingShow = false;
            dismissProcessingDialog(context);
          }
          _connectDevice(context, Ble.instance.currentDevice!);
        });
      }
    });
    Timer? oldDeviceTimer;
    if (Ble.instance.targetSoftwareVersion < Constants.KEY_VERSION_0102) {//old devices don't need to reconnect
      oldDeviceTimer = Timer(Duration(seconds: 2), () {
        if (isProcessingShow) {
          isProcessingShow = false;
          dismissProcessingDialog(context);
        }
        Fluttertoast.showToast(
            msg: S.of(context).Success,
        );
      });
    }
    isProcessingShow = true;
    await showProcessingDialogWithLongMessage(context, S.of(context).Rebooting, S.of(context).Please_wait_for_the_controller_reboot_wainting_to_reconnect, cancelable: true);
    isProcessingShow = false;
    oldDeviceTimer?.cancel();
    timer?.cancel();
    subscription.cancel();
  } else {
    await Ble.instance.disconnect();
    timer = Timer(Duration(seconds: waitSeconds), () {
      if (isProcessingShow) {
        isProcessingShow = false;
        dismissProcessingDialog(context);
      }
      _connectDevice(context, Ble.instance.currentDevice!);
    });
    isProcessingShow = true;
    await showProcessingDialogWithLongMessage(context, S.of(context).Rebooting, S.of(context).Please_wait_for_the_controller_reboot_wainting_to_reconnect, cancelable: true);
    isProcessingShow = false;
    timer.cancel();
  }
}

void rescan(BuildContext context) async {
  print('rescan');
  bool isProcessingShow = false;
  Timer? timer;
  if (Ble.instance.isConnected) {
    late StreamSubscription<DeviceState> subscription;
    subscription = Ble.instance.deviceState.listen((event) async {
      if (event == DeviceState.disconnected) {//waiting for disconnect
        print('disconnected, ready to scan');
        await subscription.cancel();
        await Ble.instance.disconnect();
        timer = Timer(Duration(seconds: 6), () {
          if (isProcessingShow) {
            isProcessingShow = false;
            dismissProcessingDialog(context);
          }
          _showDevicesDialog(context);
          Ble.instance.startScan();
        });
      }
    });
    Timer? oldDeviceTimer;
    if (Ble.instance.targetSoftwareVersion < Constants.KEY_VERSION_0102) {//old devices don't need to reconnect
      oldDeviceTimer = Timer(Duration(seconds: 2), () {
        if (isProcessingShow) {
          isProcessingShow = false;
          dismissProcessingDialog(context);
        }
        Fluttertoast.showToast(
          msg: S.of(context).Success,
        );
      });
    }
    isProcessingShow = true;
    await showProcessingDialogWithLongMessage(context, S.of(context).Rebooting, S.of(context).Please_wait_for_the_controller_reboot_wainting_to_reconnect, cancelable: true);
    isProcessingShow = false;
    oldDeviceTimer?.cancel();
    timer?.cancel();
    subscription.cancel();
  } else {
    await Ble.instance.disconnect();
    timer = Timer(Duration(seconds: 6), () {
      if (isProcessingShow) {
        isProcessingShow = false;
        dismissProcessingDialog(context);
      }
      _showDevicesDialog(context);
      Ble.instance.startScan();
    });
    isProcessingShow = true;
    await showProcessingDialogWithLongMessage(context, S.of(context).Rebooting, S.of(context).Please_wait_for_the_controller_reboot_wainting_to_reconnect, cancelable: true);
    isProcessingShow = false;
    timer.cancel();
  }
}