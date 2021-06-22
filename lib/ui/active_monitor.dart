import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pvl/generated/l10n.dart';
import 'widget/battery.dart';
import 'app_bar.dart';
import '../ble.dart';
import '../model.dart';
import 'page/detail.dart';
import 'page/info.dart';
import 'page/hist.dart';

class ActiveMonitorPage extends StatefulWidget {
  const ActiveMonitorPage({Key? key}) : super(key: key);

  @override
  _ActiveMonitorPageState createState() => _ActiveMonitorPageState();
}

class _ActiveMonitorPageState extends State<ActiveMonitorPage> with TickerProviderStateMixin {
  late StreamSubscription<DeviceState> deviceStateSubscription;
  late TabController _tabController;
  Timer? dataTimer;

  void startTimer() {
    if (dataTimer?.isActive ?? false) {
      return;
    }

    dataTimer?.cancel();
    dataTimer = Timer.periodic(Duration(milliseconds: 600), (timer) {
      switch(_tabController.index) {
        case 0:
          Ble.instance.requestStatus();
          break;
        case 1:
          Ble.instance.requestInfo();
          break;
        case 2:
          Ble.instance.requestChargeHist();
          break;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    if(Ble.instance.isConnected) {
      startTimer();
    }
    deviceStateSubscription = Ble.instance.deviceState.listen((event) {
      if (event == DeviceState.authorized) {
        startTimer();
      } else {
        dataTimer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    deviceStateSubscription.cancel();
    dataTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(context, S.of(context).Active_Monitor),
      body: Column(
          children: [
            Container(
              color: Color(0xFF41a5c9),
              padding: EdgeInsets.fromLTRB(4, 8, 4, 8),
              child: Consumer<DeviceStatus>(builder: (ctx, status, child) {
                var chargingBatteryVol = 0.0;
                bool isSolarAvailable = false;
                bool isBattery1Charging = false;
                bool isBattery2Charging = false;
                if(status.battery1ChargeEnabled) {
                  chargingBatteryVol = status.battery1Vol;
                } else {
                  chargingBatteryVol = status.battery2Vol;
                }
                if (Ble.instance.isConnected) {
                  if ((status.pvVol - chargingBatteryVol) > 0.5) {
                    isSolarAvailable = true;
                    isBattery1Charging = status.battery1ChargeEnabled;
                    isBattery2Charging = status.battery2ChargeEnabled;
                  } else {
                    isSolarAvailable = false;
                    isBattery1Charging = false;
                    isBattery2Charging = false;
                  }
                }
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    DryBatteryLevel(
                      label: '1',
                      level: status.battery1Level,
                      charging: isBattery1Charging,
                      enabled: Ble.instance.isConnected && status.battery1Vol > 0,
                    ),
                    DryBatteryLevel(
                      label: '2',
                      level: status.battery2Level,
                      charging: isBattery2Charging,
                      enabled: Ble.instance.isConnected && status.battery2Vol > 0,
                    ),
                  ],
                );
              }),
            ),
            TabBar(
              controller: _tabController,
              labelColor: Colors.cyan,
              unselectedLabelColor: Colors.black,
              tabs: <Widget>[
                Tab(
                  text: S.of(context).Detail,
                ),
                Tab(
                  text: S.of(context).Device_Info,
                ),
                Tab(
                  text: S.of(context).Charge_Hist,
                ),
              ],
            ),
            Expanded(
              child: Container(
                color: Color(0xFF383838),
                child: TabBarView(
                  controller: _tabController,
                  children: <Widget>[
                    ActiveMonitorDetail(),
                    ActiveMonitorInfo(),
                    ActiveMonitorHist(),
                  ],
                ),
              ),
            ),
          ]
      ),
    );
  }

}
