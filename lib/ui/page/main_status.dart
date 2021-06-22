import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pvl/model.dart';
import 'package:pvl/ui/dialog/common.dart';
import 'package:pvl/generated/l10n.dart';
import '../widget/flow.dart';
import '../widget/battery.dart';
import '../../constants.dart';
import '../../ble.dart';
import '../dialog/edit.dart';

class MainStatusPanel extends StatefulWidget {
  const MainStatusPanel({Key? key}) : super(key: key);

  @override
  _MainStatusPanelState createState() => _MainStatusPanelState();
}

class _MainStatusPanelState extends State<MainStatusPanel> {
  final double _iconPadding = 24.0;
  final double _lineSpace = 12.0;

  final GlobalKey _rootKey = GlobalKey();
  final GlobalKey _pvLogicKey = GlobalKey();
  final GlobalKey _solarKey = GlobalKey();
  final GlobalKey _bat1Key = GlobalKey();
  final GlobalKey _bat2Key = GlobalKey();

  Offset? _solarToControllerPosition;
  Offset? _bat1ToControllerPosition;
  Offset? _bat2ToControllerPosition;
  Offset? _solarPosition;
  Offset? _bat1Position;
  Offset? _bat2Position;

  double _deviceNameTopMargin = 20;

  void _getPosition() {
    final RenderBox rootRenderBox = _rootKey.currentContext?.findRenderObject() as RenderBox;

    final RenderBox logoRenderBox = _pvLogicKey.currentContext?.findRenderObject() as RenderBox;
    final Size logoSize = logoRenderBox.size;
    final Offset logoPosition = logoRenderBox.localToGlobal(Offset.zero);
    final Offset logoRootPos = rootRenderBox.globalToLocal(logoPosition);
    _deviceNameTopMargin = logoSize.height + 32;
    _solarToControllerPosition = Offset(logoRootPos.dx - 3, logoRootPos.dy + logoSize.height / 3.0);
    _bat1ToControllerPosition = Offset(logoRootPos.dx - 3, logoRootPos.dy + logoSize.height / 3.0 * 2.0);
    _bat2ToControllerPosition = Offset(logoRootPos.dx + logoSize.width + 3, logoRootPos.dy + logoSize.height / 3.0 * 2.0);

    final RenderBox solarRenderBox = _solarKey.currentContext?.findRenderObject() as RenderBox;
    final Size solarSize = solarRenderBox.size;
    final Offset solarPos = solarRenderBox.localToGlobal(Offset.zero);
    final solarRootPos = rootRenderBox.globalToLocal(solarPos);
    _solarPosition = Offset(solarRootPos.dx + solarSize.width + _lineSpace, solarRootPos.dy + solarSize.height / 2.0);

    final RenderBox bat1RenderBox = _bat1Key.currentContext?.findRenderObject() as RenderBox;
    final Size bat1Size = bat1RenderBox.size;
    final Offset bat1Pos = bat1RenderBox.localToGlobal(Offset.zero);
    final bat1RootPos = rootRenderBox.globalToLocal(bat1Pos);
    _bat1Position = Offset(bat1RootPos.dx + bat1Size.width + _lineSpace, bat1RootPos.dy + bat1Size.height / 2.0);

    final RenderBox bat2RenderBox = _bat2Key.currentContext?.findRenderObject() as RenderBox;
    final Size bat2Size = bat2RenderBox.size;
    final Offset bat2Pos = bat2RenderBox.localToGlobal(Offset.zero);
    final bat2RootPos = rootRenderBox.globalToLocal(bat2Pos);
    _bat2Position = Offset(bat2RootPos.dx - _lineSpace, bat2RootPos.dy + bat2Size.height / 2.0);

    setState(() {});
  }

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      _getPosition();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DeviceStatus>(builder: (ctx, status, child) {
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
        if((status.pvVol - chargingBatteryVol) > 0.5) {
          isSolarAvailable = true;
          isBattery1Charging = status.battery1ChargeEnabled;
          isBattery2Charging = status.battery2ChargeEnabled;
        } else {
          isSolarAvailable = false;
          isBattery1Charging = false;
          isBattery2Charging = false;
        }
      }

      String deviceName = '';
      if (Ble.instance.isConnected) {
        deviceName = Ble.instance.currentDevice?.name ?? '';
      }

      return Stack(
        key: _rootKey,
        children: [
          Container(
            color: Color(0xFF41a5c9),
          ),
          Center(child: Image.asset(
            'assets/images/pvlogic.png',
            key: _pvLogicKey,
            fit: BoxFit.scaleDown,
            width: 90.0,
            height: 90.0,
          ),
          ),
          Center(
            child: Container(
              padding: EdgeInsets.fromLTRB(0, _deviceNameTopMargin, 0, 0),
              child: Text(deviceName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            top: _iconPadding,
            left: _iconPadding,
            child: Image.asset(
              'assets/images/solar_cells.png',
              key: _solarKey,
              width: 64.0,
              height: 64.0,
            ),
          ),
          Positioned(
            top: _iconPadding,
            right: _iconPadding,
            child: InkWell(
              child: Image.asset(
                  'assets/images/control_setup_icon.png', width: 64.0),
              onTap: () {
                if (Ble.instance.targetSoftwareVersion >= Constants.KEY_VERSION_0102) {
                  showSettingsDialog(context);
                } else {
                  showAlertDialog(context, S.of(context).Unsupported_device, S.of(context).Target_device_does_not_support_changing_the_password);
                }
              },
            )
          ),
          Positioned(
            left: _iconPadding,
            bottom: _iconPadding,
            child: SizedBox(
              key: _bat1Key, width: 64.0, height: 64.0,
              child: BatteryLevel(
                level: status.battery1Level,
                charging: isBattery1Charging,
                enabled: Ble.instance.isConnected && status.battery1Vol > 0,
              ),
            ),
          ),
          Positioned(
            right: _iconPadding,
            bottom: _iconPadding,
            child: SizedBox(
              key: _bat2Key, width: 64.0, height: 64.0,
              child: BatteryLevel(
                level: status.battery2Level,
                charging: isBattery2Charging,
                enabled: Ble.instance.isConnected && status.battery2Vol > 0,
              ),
            ),
          ),
          Positioned(
            child: LinearFlow(
              from: _solarPosition,
              to: _solarToControllerPosition,
              point: FlowPoint.from,
              isActive: isSolarAvailable,
            ),
          ),
          Positioned(
            child: LinearFlow(
              from: _bat1ToControllerPosition,
              to: _bat1Position,
              point: FlowPoint.to,
              isActive: isBattery1Charging,
            ),
          ),
          Positioned(
            child: LinearFlow(
              from: _bat2ToControllerPosition,
              to: _bat2Position,
              point: FlowPoint.to,
              isActive: isBattery2Charging,
            ),
          ),
        ],
      );
    });
  }
}
