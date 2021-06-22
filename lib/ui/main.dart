import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lifecycle/lifecycle.dart';
import 'package:pvl/generated/l10n.dart';
import 'package:pvl/ui/dialog/common.dart';
import 'anim/route.dart';
import 'active_monitor.dart';
import 'dashboard.dart';
import 'battery_options.dart';
import 'profiles.dart';
import 'widget/button.dart';
import 'widget/door.dart';
import 'page/main_status.dart';
import '../ble.dart';
import 'ble_dialog.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with LifecycleAware, LifecycleMixin {
  StreamSubscription<DeviceState>? deviceStateSubscription;
  StreamSubscription<DeviceInd>? deviceIndSubscription;
  Timer? dataTimer;
  DoorAction doorAction = DoorAction.close;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _unlistenDeviceState();
    super.dispose();
  }

  void _listenDeviceState() {
    if (deviceStateSubscription != null) {
      return;
    }
    _checkState(Ble.instance.currentDeviceState);
    deviceStateSubscription = Ble.instance.deviceState.listen((state) {
      print('MainPage event: $state');
      _checkState(state);
    });
  }

  void _checkState(DeviceState state) {
    dataTimer?.cancel();
    if (state == DeviceState.authorized) {
      doorAction = DoorAction.open;
      dataTimer = Timer.periodic(Duration(milliseconds: 1000), (timer) {
        Ble.instance.requestStatus();
      });
      deviceIndSubscription?.cancel();
      deviceIndSubscription = Ble.instance.deviceInd.listen((event) async {
        switch (event) {
          case DeviceInd.nameChanged:
            // await showAlertDialog(context, S.of(context).Success, S.of(context).Please_wait_for_controller_reboot_You_need_reconnect_device_to_take_effects);
            rescan(context);
            break;
          case DeviceInd.passwordChanged:
            reconnect(context, waitSeconds: 6);
            break;
          default:
            break;
        }
      });
      setState(() {});
    } else if (state == DeviceState.disconnected) {
      doorAction = DoorAction.close;
      setState(() {});
    }
  }

  void _unlistenDeviceState() {
    deviceStateSubscription?.cancel();
    deviceStateSubscription = null;
    deviceIndSubscription?.cancel();
    deviceIndSubscription = null;
    dataTimer?.cancel();
    dataTimer = null;
  }

  @override
  void onLifecycleEvent(LifecycleEvent event) {
    switch (event) {
      case LifecycleEvent.push:
      case LifecycleEvent.active:
        _listenDeviceState();
        break;
      case LifecycleEvent.invisible:
      case LifecycleEvent.inactive:
        _unlistenDeviceState();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: Stack(
            children: [
              MainStatusPanel(),
              Door(action: doorAction, onPressed: () {
                blueIconClick(context);
              },),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: _getCardPanel(),
        ),
      ],
    );
  }

  Widget _getCardPanel() {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      decoration: const BoxDecoration(
        gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 1.0],
            //渐变颜色[始点颜色, 结束颜色]
            colors: [Colors.white, Color(0xFF19AAE1)]
        )
      ),
      child: Column(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: MainButton(
                    icon: 'assets/images/activity_monitor_launch_icon.png',
                    text: S
                        .of(context)
                        .Active_Monitor,
                    color: Color(0xFF877DFF),
                    onPressed: () {
                      Navigator.push(context,
                          RightToLeftBuilder(ActiveMonitorPage()));
                    },
                  ),
                ),
                Expanded(
                  child: MainButton(
                    icon: 'assets/images/dashboard_launch_icon.png',
                    text: S
                        .of(context)
                        .Dashboard,
                    color: Color(0xFF39A3F3),
                    onPressed: () {
                      // Navigator.pushNamed(context, '/dashboard');
                      Navigator.push(context,
                          RightToLeftBuilder(DashboardPage()));
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: MainButton(
                  icon: 'assets/images/battery_launch_icon.png',
                  text: S
                      .of(context)
                      .Battery_Options,
                  color: Color(0xFFF3A239),
                  onPressed: () {
                    Navigator.push(context,
                        RightToLeftBuilder(BatteryOptionsPage()));
                  },
                ),
              ),
              Expanded(
                child: MainButton(
                  icon: 'assets/images/profile_launch_icon.png',
                  text: S
                      .of(context)
                      .Profiles,
                  color: Color(0xFFF35539),
                  onPressed: () {
                    // Navigator.pushNamed(context, '/profiles');
                    Navigator.push(context,
                        RightToLeftBuilder(ProfilesPage()));
                  },
                ),
              ),
            ],
          ),
          ),
        ],
      ),
    );
  }

}
