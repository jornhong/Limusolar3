import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:io';
import 'package:flutter_blue/flutter_blue.dart';
import 'util/protocol.dart';
import 'model.dart';
import 'data/preset.dart';
import 'constants.dart';

enum DeviceState {
  idle,
  disconnected,
  bleConnecting,
  bleConnected,
  handshaking,
  handshakeFailed,
  handshake,
  queryInfo,
  needAuth,
  authFailed,
  authorized,
}

enum DeviceInd {
  normal,
  batteryOptionsRead,
  batteryOptionsWrite,
  nameChanged,
  passwordChanged,
  reset,
}

class Ble {
  FlutterBlue flutterBlue = FlutterBlue.instance;

  Ble._();
  static Ble _instance = new Ble._();
  static Ble get instance => _instance;
  StreamSubscription<BluetoothDeviceState>? _deviceStateSubscription;
  Timer? _connectTimer;
  Timer? _discoverServicesTimer;
  StreamSubscription<List<int>>? _dataSubscription;
  BluetoothCharacteristic? _characteristic;

  Stream<BluetoothState> get state => _bluetoothStateSc.stream;
  Stream<List<ScanResult>> get scanResults => flutterBlue.scanResults;
  BluetoothDevice? _device;
  BluetoothDevice? get currentDevice => _device;
  Future<BluetoothDevice?> get connectedDevice async {
    List<BluetoothDevice> list = await flutterBlue.connectedDevices;
    if (list.isNotEmpty) {
      return list[0];
    } else {
      return null;
    }
  }

  StreamController<BluetoothState> _bluetoothStateSc = StreamController<BluetoothState>.broadcast();
  StreamController<DeviceState> _deviceStateSc = StreamController<DeviceState>.broadcast();
  StreamController<DeviceInd> _deviceIndSc = StreamController<DeviceInd>.broadcast();
  DeviceState _prevDeviceState = DeviceState.idle;
  DeviceState _deviceState = DeviceState.idle;
  DeviceState get currentDeviceState => _deviceState;
  Stream<DeviceState> get deviceState => _deviceStateSc.stream;
  DeviceState get prevDeviceState => _prevDeviceState;
  Stream<DeviceInd> get deviceInd => _deviceIndSc.stream;

  BluetoothState bluetoothState = BluetoothState.off;
  bool get isConnected => _deviceState == DeviceState.authorized;
  bool _hasHeader = false;
  List<int> _frame = <int>[];
  int _mtu = 20;
  int _targetSoftwareVersion = 0;
  int get targetSoftwareVersion => _targetSoftwareVersion;

  var bleSession = BleSession();
  var deviceStatus = DeviceStatus();
  var systemInfo = SystemInfo();
  var eventLog = EventLog();
  var batteryOption = BatteryOption.copyFrom(Constants.batteryTypeSealed);
  var customBatteryOption = BatteryOption.copyFrom(Constants.batteryTypeCustom);

  StreamSubscription<BluetoothState>? _bluetoothStateSubscription;
  Future init() async {
    _bluetoothStateSubscription?.cancel();
    _bluetoothStateSubscription = flutterBlue.state.listen((state) {
      bluetoothState = state;
      _bluetoothStateSc.add(state);
      if(state == BluetoothState.off) {//disable bluetooth by user
        if (isConnected) {
          disconnect();
          _setState(DeviceState.disconnected);
        }
      }
      print('BluetoothState: $state');
    });

    customBatteryOption = await Preset.getCustomBatteryOptions();
    print('Ble init');
  }

  Future dispose() async {
    _connectTimer?.cancel();
    _bluetoothStateSubscription?.cancel();
    await stopScan();
    await disconnect();
    print('Ble dispose');
  }

  void _setState(DeviceState state) {
    if (_deviceState != state) {
      _prevDeviceState = _deviceState;
      _deviceState = state;
      _deviceStateSc.add(state);
    }
  }

  Future<bool> startScan() async {
    if (await flutterBlue.state.first == BluetoothState.on) {
      flutterBlue.startScan(
          withServices: [Guid('0000fff0-0000-1000-8000-00805f9b34fb')]);
      return true;
    } else {
      print('bluetooth is not on.');
      return false;
    }
  }

  Future<void> stopScan() async {
    await flutterBlue.stopScan();
  }

  Future<bool?> connect(BluetoothDevice device) async {
    print('ble connect: $device');
    _deviceStateSubscription?.cancel();
    _characteristic = null;
    _setState(DeviceState.idle);
    _deviceStateSubscription = device.state.listen((state) async {
      print('ble device state: $state');
      if (state == BluetoothDeviceState.disconnected) {//每次连接都会先触发断开
        if (_deviceState == DeviceState.idle) {
          if (Platform.isAndroid) {
            _setState(DeviceState.bleConnecting);
          }
        } else {
          _setState(DeviceState.disconnected);
        }
      } else if(state == BluetoothDeviceState.connected) {
        _setState(DeviceState.bleConnected);
        _discoverServicesTimer?.cancel();

        _mtu = await device.mtu.first;
        if (_mtu < 1) {
          _mtu = 8;
        }
        print('mtu: $_mtu');
        _discoverServicesTimer = Timer(Duration(milliseconds: 100), () {
          _discoverServices(device);
        });
      }
    });

    // _setState(DeviceState.bleConnecting);
    _connectTimer?.cancel();//用这个timer辅助处理连接超时
    _connectTimer = Timer(Duration(seconds: 8), () {
      _deviceStateSubscription?.cancel();
      _setState(DeviceState.disconnected);
      disconnect();
    });

    _device = device;
    Future<bool>? returnValue;
    if (Platform.isIOS) {
      _setState(DeviceState.bleConnecting);
    }
    await device.connect(autoConnect: false).timeout(Duration(seconds: 6), onTimeout: () {
      print('timeout occured');
      _connectTimer?.cancel();
      _deviceStateSubscription?.cancel();
      _setState(DeviceState.disconnected);
      returnValue = Future.value(false);
      device.disconnect();
    }).then((data) {
      if(returnValue == null) {
        _connectTimer?.cancel();
        print('connection successful');
        returnValue = Future.value(true);
      }
    });
    return returnValue;

    // try {
    //   _device = device;
    //   await device.connect(timeout: Duration(seconds: 7), autoConnect: false);
    //   _connectTimer?.cancel();
    // } catch (e) {//bug,这里不能捕捉到timeout的异常
    //   _connectTimer?.cancel();
    //   _deviceStateSubscription?.cancel();
    //   _setState(DeviceState.disconnected);
    //   print('****************');
    //   print(e);
    //   return;
    // }
  }

  Future _discoverServices(BluetoothDevice device) async {
    print('_discoverServices');
    List<BluetoothService> services = await device.discoverServices();
    for (var service in services) {
      var characteristics = service.characteristics;
      for (var characteristic in characteristics) {
        if (characteristic.uuid.toString() == '0000fff1-0000-1000-8000-00805f9b34fb') {
          _characteristic = characteristic;
          print('characteristic is found.');
          Timer(Duration(milliseconds: 100), () {
            _setupCharacteristic();
          });
          // Future.delayed(const Duration(milliseconds: 100), () => _setupCharacteristic);
          break;
        }
      }
      if (_characteristic != null) {
        break;
      }
    }

    if (_characteristic == null) {
      device.disconnect();
    }
  }

  void _setupCharacteristic() async {
    print('_setupCharacteristic');
    if (_characteristic?.properties.read == true) {
      await _characteristic?.setNotifyValue(false);
    }
    // if (_characteristic?.properties.notify == true) {
    //   await _characteristic?.setNotifyValue(true);
    // }
    await _characteristic?.setNotifyValue(true);
    // var descriptors = _characteristic?.descriptors;
    // if (descriptors != null) {
    //   for (BluetoothDescriptor d in descriptors) {
    //     if (d.uuid.toString() == '00002902-0000-1000-8000-00805f9b34fb') {
    //       await d.write([0x01, 0x00]);
    //       break;
    //     }
    //   }
    // }
    Timer(Duration(milliseconds: 500), () {
      _dataCallback();
    });
  }

  static const frameHE = 1;//一个完整的帧
  static const frameH = 2;//有帧头,没有帧尾
  static const frameE = 3;//有帧尾,没有帧头
  static const frameB = 4;//没有帧头也没有帧尾

  void _dataCallback() {
    print('_dataCallback');
    bleSession.clear();
    bleSession.time = DateTime.now().millisecondsSinceEpoch;
    _dataSubscription?.cancel();
    _dataSubscription = _characteristic?.value.listen((value) {
      // print(hexString(value, label: 'raw'));
      if (value.isEmpty) {
        return;
      }

      bleSession.incRxBytes(value.length);

      bool hasFrame = false;
      int frameSign = 0;
      if (value.first == Protocol.FRAME_HEADER && value.last == Protocol.FRAME_END) {
        if (value.length > 1) {
          frameSign = frameHE;
        } else {
          if (_hasHeader) {
            frameSign = frameE;
          } else {
            frameSign = frameH;
          }
        }
      } else if (value.first == Protocol.FRAME_HEADER) {
        frameSign = frameH;
      } else if (value.last == Protocol.FRAME_END) {//出现帧尾
        frameSign = frameE;
      } else {//没有帧头也没有帧尾
        frameSign = frameB;
      }

      switch (frameSign) {
        case frameHE:
          _frame.clear();
          _frame.addAll(value);
          _hasHeader = false;
          hasFrame = true;
          break;
        case frameH:
          _hasHeader = true;
          _frame.clear();
          _frame.addAll(value);
          break;
        case frameE:
          if (_hasHeader) {//如果有帧头
            if (_frame.length > 1) {//完整帧
              _frame += value;
              _hasHeader = false;
              hasFrame = true;
            } else {//连续的帧头
              _frame.clear();
            }
          } else {//没有帧头却出现帧尾
            if (value.length > 1) {
              _hasHeader = false;
              _frame.clear();
            } else {//只一个c0,把这个当成帧头
              _hasHeader = true;
              _frame.clear();
              _frame.addAll(value);
            }
          }
          break;
        case frameB:
          if (_hasHeader) {//纯数据
            _frame += value;
          } else {
            _hasHeader = false;
            print(hexString(value, label: 'read error'));
          }
          break;
      }

      if (hasFrame) {
        var frame = Protocol.slipUnesc(_frame);
        _frame.clear();
        // print(hexString(frame, label: 'read'));

        if (frame.length < Protocol.minLength) {
          print('error, frame length is ${frame.length}');
          return;
        }

        bleSession.incRxFrames(1);

        int crc = Protocol.crc16(frame.sublist(0, frame.length - 2));
        int fcrc = frame[frame.length - 1] + (frame[frame.length - 2] << 8);
        if (crc != fcrc) {
          bleSession.incRxErrors(1);
          print('crc error! frame crc: $fcrc calc: $crc');
        }
        parse(frame);
      }
    });

    Timer(Duration(milliseconds: 3000), () {//如果3秒不回应握手
      if (_deviceState == DeviceState.handshaking) {
        _setState(DeviceState.handshakeFailed);
      }
    });
    _setState(DeviceState.handshaking);
    sendHandshake();
  }

  Future<void> disconnect() async {
    // await _deviceStateSubscription?.cancel();
    await _dataSubscription?.cancel();
    await (await connectedDevice)?.disconnect();
    _hasHeader = false;
    _frame.clear();
  }

  Future<void> _write(List<int> data) async {
    // print(hexString(data, label: 'write'));
    var frame = Protocol.slipFrame(data);
    // print(hexString(frame, label: 'write'));
    bleSession.incTxBytes(frame.length);
    bleSession.incTxFrames(1);
    try {
      if (frame.length <= _mtu) {
        await _characteristic?.write(frame);
      } else {
        int count = (frame.length / _mtu).floor();
        for (int i = 0; i < count; i++) {
          await _characteristic?.write(frame.sublist(i * _mtu, _mtu));
        }
        await _characteristic?.write(frame.sublist(count * _mtu));
      }
    } catch (e) {
      disconnect();
      print(e);
    }
  }

  void sendHandshake() {
    int millis = DateTime.now().millisecondsSinceEpoch;
    // var tempKeys = [millis >> 32, millis & 0xFFFFFFFF];
    // btea(tempKeys, 2, privateKey);
    var data = [0x01, 0x08] + int64bytes(millis);
    _write(data);
  }

  void sendGetDeviceSwVersion() {
    _write([0x25, 0x02, 0xA0, 0x20]);
  }

  void sendAuthorizion(String password) {
    List<int> bytes = utf8.encode(password);
    var min = math.min(bytes.length, 6);
    var data = List.filled(6, 0);
    for (int i = 0; i < min; i++) {
      data[i] = bytes[i];
    }
    _write([0x52, 0x06, 0xA0] + data);
  }

  static const clientIndentification = 0xA0;
  void requestStatus() {
    _write([0x20, 0x02, clientIndentification, 0x20]);
  }
  void requestInfo() {
    _write([0x25, 0x02, clientIndentification, 0x20]);
  }
  void requestChargeHist() {
    _write([0x24, 0x02, clientIndentification, 0x20]);
  }
  void requestBatteryOptions() {
    _write([0x26, 0x02, clientIndentification, 0x00]);
  }

  void writeBatteryOptions(BatteryOption batteryOption) {
    _write([0x27, 19, clientIndentification] + Protocol.toRawData(batteryOption));
  }

  void writePassword(String password) {
    List<int> bytes = utf8.encode(password);
    var min = math.min(bytes.length, 6);
    var data = List.filled(6, 0);
    for (int i = 0; i < min; i++) {
      data[i] = bytes[i];
    }
    _write([0x51, 0x06, clientIndentification] + data);
  }

  void writeDeviceName(String name) {
    List<int> bytes = utf8.encode(name);
    var min = math.min(bytes.length, 6);
    var data = List.filled(6, 0);
    for (int i = 0; i < min; i++) {
      data[i] = bytes[i];
    }
    _write([0x50, 0x06, clientIndentification] + data);
  }

  void resetDevice() {
    _write([0x80, 0x02, clientIndentification, 0xAA, 0x55]);
  }

  void parse(List<int> frame) {
    if (frame.length < Protocol.minLength) {
      print('error, frame length is ${frame.length}');
      return;
    }
    switch(frame.first) {
      case 0x01:
        _setState(DeviceState.handshake);
        _setState(DeviceState.queryInfo);
        sendGetDeviceSwVersion();
        break;
      case 0x20:
        if (frame.length > 7) {
          Protocol.parseDeviceStatus(frame, deviceStatus);
        // print('bat1: ${deviceStatus.battery1Vol}');
        }
        break;
      case 0x24:
        Protocol.parseChargeHist(frame, eventLog);
        break;
      case 0x25://catch sysinfo frame
        if(frame.length > 28) {
          Protocol.parseDeviceInfo(frame, systemInfo);
          _targetSoftwareVersion = (frame[27] << 8) + frame[28];
          // print('softwareVersion: 0x${targetSoftwareVersion.toRadixString(16)}');
          if (_deviceState != DeviceState.authorized) {
            if(_targetSoftwareVersion >= Constants.KEY_VERSION_0102) {
              _setState(DeviceState.needAuth);
              // sendAuthorizion('321321');
            } else {
              _setState(DeviceState.authorized);
            }
          }
        }
        break;
      case 0x26:
        Protocol.parseBatteryOptions(frame, batteryOption);
        Preset.saveCurrentBatteryOptions(batteryOption);
        Preset.saveVoltageType(batteryOption.systemType);
        Preset.saveBatteryType(batteryOption.batteryType);
        if (batteryOption.batteryType == Constants.BATTERY_TYPE_CUSTOM) {
          customBatteryOption.copyFrom(batteryOption);
          Preset.saveCustomBatteryOptions(batteryOption);
        }
        _deviceIndSc.add(DeviceInd.batteryOptionsRead);
        break;
      case 0x27:
        _deviceIndSc.add(DeviceInd.batteryOptionsWrite);
        break;
      case 0x50:
        _deviceIndSc.add(DeviceInd.nameChanged);
        disconnect();
        break;
      case 0x51:
        _deviceIndSc.add(DeviceInd.passwordChanged);
        disconnect();
        break;
      case 0x52://get auth result
        if(frame[2] == 0x01) {//auth success
          _setState(DeviceState.authorized);
        } else {
          _setState(DeviceState.authFailed);
          disconnect();
        }
        break;
      case 0x80:
        _deviceIndSc.add(DeviceInd.reset);
        print('reset success');
        break;
    }

  }
}