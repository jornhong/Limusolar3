import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wakelock/wakelock.dart';
import 'package:pvl/generated/l10n.dart';
import 'widget/meter.dart';
import '../ble.dart';
import '../model.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late StreamSubscription<DeviceState> deviceStateSubscription;
  Timer? dataTimer;
  bool battery1Charging = false;
  bool battery2Charging = false;
  String leftIndIcon = 'assets/images/left_charge_frame_icon.png';
  String rightIndIcon = 'assets/images/right_charge_frame_icon.png';
  double leftIndOpacity = 1.0, rightIndOpacity = 1.0;
  final GlobalKey _meter1Key = GlobalKey();
  double _frameRadius = 0;

  void startTimer() {
    if (dataTimer?.isActive ?? false) {
      return;
    }
    dataTimer?.cancel();
    dataTimer = Timer.periodic(Duration(milliseconds: 600), (timer) {
      Ble.instance.requestStatus();
    });
  }

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    // SystemChrome.setPreferredOrientations([
    //     DeviceOrientation.landscapeLeft,
    //     DeviceOrientation.landscapeRight,
    //   ]
    // );
    SystemChrome.setEnabledSystemUIOverlays ([]);

    _frameRadius = 10;
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      final RenderBox meterRenderBox = _meter1Key.currentContext?.findRenderObject() as RenderBox;
      final Size meterSize = meterRenderBox.size;
      _frameRadius = math.min(meterSize.width, meterSize.height) / 2;
      setState(() {});
    });

    _setupInd();
    setState(() {});

    if(Ble.instance.isConnected) {
      startTimer();
    }
    deviceStateSubscription = Ble.instance.deviceState.listen((event) {
      if (event == DeviceState.authorized) {
        startTimer();
      } else {
        dataTimer?.cancel();
        _setupInd();
        setState(() {});
      }
    });

  }

  _setupInd() {
    if (!Ble.instance.isConnected) {
      leftIndIcon = "assets/images/left_charge_frame_icon.png";
      rightIndIcon = "assets/images/right_charge_frame_icon.png";
      leftIndOpacity = 0.5;
      rightIndOpacity = 0.5;
      return;
    }

    if(battery1Charging) {
      leftIndIcon = "assets/images/left_charge_icon.png";
      if(leftIndOpacity > 0) {
        leftIndOpacity = 0;
      } else {
        leftIndOpacity = 1;
      }
    } else {
      leftIndIcon = "assets/images/left_charge_frame_icon.png";
      leftIndOpacity = 0.3;
    }

    if(battery2Charging) {
      if(rightIndOpacity > 0) {
        rightIndOpacity = 0;
      } else {
        rightIndOpacity = 1;
      }
      rightIndIcon = "assets/images/right_charge_icon.png";
    } else {
      rightIndIcon = "assets/images/right_charge_frame_icon.png";
      rightIndOpacity = 0.3;
    }
  }

  @override
  void dispose() {
    super.dispose();
    Wakelock.disable();
    deviceStateSubscription.cancel();
    dataTimer?.cancel();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.portraitUp,
    //   DeviceOrientation.portraitDown,
    // ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: RotatedBox(
          quarterTurns: 1,
          child: Consumer<DeviceStatus>(builder: (ctx, status, child) {
            return _getContent(status);
          }),
        ),
      ),
    );
  }

  Widget _getContent(DeviceStatus status) {
    String deviceName;
    if (Ble.instance.isConnected) {
      deviceName = Ble.instance.currentDevice?.name ?? '';
    } else {
      deviceName = S.of(context).Device_Not_Connected;
    }
    if(status.pvAvailible) {
      battery1Charging = status.battery1ChargeEnabled;
      battery2Charging = status.battery2ChargeEnabled;
    } else {
      battery1Charging = false;
      battery2Charging = false;
    }
    _setupInd();
    return Stack(
      children: [
        Positioned(
          top: 56,
          left: 0,
          right: 0,
          child: Center(
            child: Text(deviceName, style: TextStyle(fontSize: 24.0, color: Color(0xFF69E6E6)),),
          ),
        ),
        Positioned(
          top: 32,
          left: 8,
          right: 8,
          bottom: 8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                flex: 2,
                child: BatteryMeter(
                  key: _meter1Key,
                  label: S.of(context).BAT1,
                  charging: battery1Charging,
                  enabled: Ble.instance.isConnected,
                  masterIndicaterColor: Color(0xFF00DDDD),
                  subIndicaterColor: Color(0xFFAAAAAA),
                  maxValue: 44.0,
                  value: status.battery1Vol,
                  batteryLevel: status.battery1Level,
                  chargeCurrent: status.battery1ChargeCurrent,
                  frameRadius: _frameRadius,
                ),
              ),
              SizedBox(width: 8,),
              Opacity(
                opacity: leftIndOpacity,
                child: Image.asset(leftIndIcon, width: 32,),
              ),
              SizedBox(width: 8,),
              Expanded(
                flex: 1,
                child: PvMeter(
                  tickMarkBoldColor: Color(0xFF00DDDD),
                  tickMarkColor: Color(0xFFAAAAAA),
                  maxValue: 44.0,
                  value: status.pvVol,
                ),
              ),
              SizedBox(width: 8,),
              Opacity(
                opacity: rightIndOpacity,
                child: Image.asset(rightIndIcon, width: 32,),
              ),
              SizedBox(width: 8,),
              Expanded(
                flex: 2,
                child: BatteryMeter(
                  label: S.of(context).BAT2,
                  charging: battery2Charging,
                  enabled: Ble.instance.isConnected,
                  masterIndicaterColor: Color(0xFF00DDDD),
                  subIndicaterColor: Color(0xFFAAAAAA),
                  value: status.battery2Vol,
                  batteryLevel: status.battery2Level,
                  chargeCurrent: status.battery2ChargeCurrent,
                  maxValue: 44.0,
                  frameRadius: _frameRadius,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 16,
          left: 16,
          child: OutlinedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              side: BorderSide(width: 2, color: Colors.grey),
            ),
            child: Container(
              child: Icon(Icons.arrow_back_ios_outlined, color: Colors.white,),
            ),
          ),
        ),
      ],
    );
  }

  double _getFrameRadius() {
    var width = MediaQuery.of(context).size.width * 0.5;
    var height = MediaQuery.of(context).size.height * 0.66;
    return math.min(width, height) / 2;
  }
}
