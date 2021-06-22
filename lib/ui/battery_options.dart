import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pvl/data/preset.dart';
import 'package:pvl/ui/ble_dialog.dart';
import 'package:pvl/ui/dialog/common.dart';
import 'package:pvl/generated/l10n.dart';
import 'widget/table.dart';
import 'app_bar.dart';
import '../constants.dart';
import '../ble.dart';
import '../model.dart';

class BatteryOptionsPage extends StatefulWidget {
  const BatteryOptionsPage({Key? key}) : super(key: key);

  @override
  _BatteryOptionsPageState createState() => _BatteryOptionsPageState();
}

class _BatteryOptionsPageState extends State<BatteryOptionsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  BatteryOption _batteryOption = Ble.instance.batteryOption;
  bool _init = false;
  StreamSubscription<DeviceInd>? deviceIndSubscription;
  bool _isShowSendingDialog = false;

  static List<DropdownMenuItem<int>> _voltageTypes = [
    DropdownMenuItem<int>(value: Constants.BATTERY_SYSTEM_TYPE_AUTO, child: Text('  12V/24V Auto'),),
    DropdownMenuItem<int>(value: Constants.BATTERY_SYSTEM_TYPE_12, child: Text('  12V'),),
    DropdownMenuItem<int>(value: Constants.BATTERY_SYSTEM_TYPE_24, child: Text('  24V'),),
  ];

  Future<void> init() async {
    _batteryOption = Provider
        .of<BatteryOption>(context, listen: false);
    _batteryOption.systemType = await Preset.getVoltageType();
    _batteryOption.batteryType = await Preset.getBatteryType();
    _init = true;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    init();
    _tabController = TabController(length: 5, vsync: this)..addListener(() {
      switch(_tabController.index) {
        case 0:
          _batteryOption.batteryType = Constants.BATTERY_TYPE_SEALED;
          _batteryOption.copyParam(Constants.batteryTypeSealed);
          break;
        case 1:
          _batteryOption.batteryType = Constants.BATTERY_TYPE_COLLOID;
          _batteryOption.copyParam(Constants.batteryTypeColloid);
          break;
        case 2:
          _batteryOption.batteryType = Constants.BATTERY_TYPE_OPEN;
          _batteryOption.copyParam(Constants.batteryTypeOpen);
          break;
        case 3:
          _batteryOption.batteryType = Constants.BATTERY_TYPE_LIFOS;
          _batteryOption.copyParam(Constants.batteryTypeLifos);
          break;
        case 4:
          // if (_isCustomEnabled()) {
            _batteryOption.batteryType = Constants.BATTERY_TYPE_CUSTOM;
            _batteryOption.copyParam(Ble.instance.customBatteryOption);
          // } else {
          //   int index = _tabController.previousIndex;
          //   setState(() {
          //     _tabController.index = index;
          //   });
          //   return;
          // }

          break;
      }
      if (_init) {
        Preset.saveBatteryType(_batteryOption.batteryType); //性能考虑单独保存
      }
    });

    deviceIndSubscription = Ble.instance.deviceInd.listen((event) async {
      print('batteryType: ${_batteryOption.batteryType}');
      switch (event) {
        case DeviceInd.batteryOptionsRead:
          setState(() {});
          Fluttertoast.showToast(
              msg: S.of(context).Read_success
          );
          break;
        case DeviceInd.batteryOptionsWrite:
          // await Ble.instance.disconnect();
          _dismissSendingDialog();
          // await showAlertDialog(context, S.of(context).Success, S.of(context).Please_wait_for_controller_reboot_You_need_reconnect_device);
          reconnect(context);
          break;
        default:
          break;
      }
    });
  }

  @override
  void dispose() {
    deviceIndSubscription?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch(_batteryOption.batteryType) {
      case Constants.BATTERY_TYPE_SEALED:
        _tabController.index = 0;
        break;
      case Constants.BATTERY_TYPE_COLLOID:
        _tabController.index = 1;
        break;
      case Constants.BATTERY_TYPE_OPEN:
        _tabController.index = 2;
        break;
      case Constants.BATTERY_TYPE_LIFOS:
        _tabController.index = 3;
        break;
      case Constants.BATTERY_TYPE_CUSTOM:
        _tabController.index = 4;
        break;
    }

    return Scaffold(
      appBar: MyAppBar(context, S.of(context).Battery_Options),
      body: Column(
        children: [
          Container(
            color: Color(0xFF41a5c9),
            padding: EdgeInsets.fromLTRB(8, 24, 8, 24),
            child: Row(
              children: [
                Text('${S.of(context).System_Voltage}:',
                  style: TextStyle(fontSize: 16.0, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 4,),
                Expanded(child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black38, width: 1),
                    //边框圆角设置
                    borderRadius: BorderRadius.vertical(
                        top: Radius.elliptical(4, 4),
                        bottom: Radius.elliptical(4, 4)),
                  ),
                  child: DropdownButton<int>(
                    items: _voltageTypes,
                    value: _batteryOption.systemType,
                    isExpanded: true,
                    underline: Text(''),
                    onChanged: (value) {
                      _batteryOption.systemType = value ?? Constants.BATTERY_SYSTEM_TYPE_AUTO;
                      print('_batteryOption.systemType: ${_batteryOption.systemType}');
                      Preset.saveVoltageType(_batteryOption.systemType);
                      if (_batteryOption.systemType == Constants.BATTERY_SYSTEM_TYPE_AUTO
                        && _batteryOption.batteryType == Constants.BATTERY_TYPE_CUSTOM) {
                        _tabController.index = 3;
                      }
                      setState(() {});
                    },
                  ),
                ),),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            labelColor: Colors.cyan,
            unselectedLabelColor: Colors.black,
            labelStyle: TextStyle(fontSize: 12.0,),
            tabs: <Widget>[
              Tab(
                text: S.of(context).SEALED,
              ),
              Tab(
                text: S.of(context).GEL,
              ),
              Tab(
                text: S.of(context).FLOODED,
              ),
              Tab(
                text: S.of(context).LIFOS,
              ),
              Tab(
                child: Text(S.of(context).CUSTOM, overflow: TextOverflow.ellipsis,),
              ),
            ],
          ),
          Expanded(
            child: Container(
              child: TabBarView(
                controller: _tabController,
                children: <Widget>[
                  BatteryParamTable(batteryOption: _batteryOption,),
                  BatteryParamTable(batteryOption: _batteryOption,),
                  BatteryParamTable(batteryOption: _batteryOption,),
                  BatteryParamTable(batteryOption: _batteryOption,),
                  BatteryParamTable(batteryOption: _batteryOption,),
                ],
              ),
            ),
          ),
          const Divider(height: 1,),
          Container(
            padding: EdgeInsets.all(4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Image.asset('assets/images/read_icon.png', width: 24.0, color: Colors.black87,),
                    label: Text(S.of(context).Read),
                    onPressed: _onReadPressed,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.fromLTRB(0, 12.0, 0, 12.0),
                    ),
                  ),
                ),
                SizedBox(width: 2,),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Image.asset('assets/images/send_icon.png', width: 24.0, color: Colors.black87,),
                    label: Text(S.of(context).Send),
                    onPressed: _onSendPressed,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.fromLTRB(0, 12.0, 0, 12.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onReadPressed() {
    if (!Ble.instance.isConnected) {
      Fluttertoast.showToast(
          msg: S.of(context).Remote_Controller_Not_Connected
      );
      return;
    }
    Ble.instance.requestBatteryOptions();
  }

  void _onSendPressed() {
    if (!Ble.instance.isConnected) {
      Fluttertoast.showToast(
          msg: S.of(context).Remote_Controller_Not_Connected
      );
      return;
    }
    if (_batteryOption.systemType == Constants.BATTERY_SYSTEM_TYPE_AUTO
        && _batteryOption.batteryType == Constants.BATTERY_TYPE_CUSTOM) {
      showAlertDialog(context, S.of(context).Error, S.of(context).System_Voltage_is_Auto_CUSTOM_param_is_not_allowed);
      return;
    }
    _showSendingDialog();
    Ble.instance.writeBatteryOptions(_batteryOption);
  }

  Timer? sendTimer;
  void _showSendingDialog() {
    if (_isShowSendingDialog) {
      return;
    }
    _isShowSendingDialog = true;
    showProcessingDialog(context, Ble.instance.currentDevice?.name ?? S.of(context).Tips,
        S.of(context).Please_wait);
    sendTimer = Timer(Duration(seconds: 3), () {
      _dismissSendingDialog();
      showAlertDialog(context, S.of(context).Error, S.of(context).Failure);
    });
  }

  void _dismissSendingDialog() {
    sendTimer?.cancel();
    if (_isShowSendingDialog) {
      _isShowSendingDialog = false;
      dismissProcessingDialog(context);
    }
  }
}
