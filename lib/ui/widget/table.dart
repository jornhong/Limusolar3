import 'package:flutter/material.dart';
import 'package:pvl/model.dart';
import 'package:pvl/ui/dialog/common.dart';
import '../../constants.dart';
import '../../data/preset.dart';
import '../../ble.dart';

class BatteryParamTable extends StatefulWidget {
  const BatteryParamTable({Key? key, required this.batteryOption}) : super(key: key);
  final BatteryOption batteryOption;

  @override
  _BatteryParamTableState createState() => _BatteryParamTableState();
}

class _BatteryParamTableState extends State<BatteryParamTable> {

  bool enabled = false;

  bool _isEnabled() {
    return widget.batteryOption.systemType != Constants.BATTERY_SYSTEM_TYPE_AUTO
    && widget.batteryOption.batteryType == Constants.BATTERY_TYPE_CUSTOM;
  }

  @override
  Widget build(BuildContext context) {
    double scale = widget.batteryOption.systemType == Constants.BATTERY_SYSTEM_TYPE_24 ? 2 : 1;

    return ListView(
        children: <Widget>[
          ParamRow(
            label: Constants.equDurationParam.title,
            value: widget.batteryOption.equDuration,
            param: Constants.equDurationParam,
            backgroundColor: Color(0xFFD7FFFF),
            enabled: _isEnabled(),
            onPressed: () async {
              var ret = await showSpinDialog(
                context: context,
                param: Constants.equDurationParam,
                value: widget.batteryOption.equDuration.toDouble(),
              );
              if (ret != null) {
                setState(() {
                  widget.batteryOption.equDuration = ret.toInt();
                  Ble.instance.customBatteryOption.equDuration = widget.batteryOption.equDuration;
                  Preset.saveCustomBatteryOptions(widget.batteryOption);
                });
              }
            },
          ),
          ParamRow(
            label: Constants.equVoltageParam.title,
            value: widget.batteryOption.equVol * scale,
            param: Constants.equVoltageParam,
            enabled: _isEnabled(),
            onPressed: () async {
              var ret = await showSpinDialog(
                context: context,
                param: Constants.equVoltageParam,
                value: widget.batteryOption.equVol,
                scale: scale,
              );
              if (ret != null) {
                setState(() {
                  widget.batteryOption.equVol = ret;
                  Ble.instance.customBatteryOption.equVol = widget.batteryOption.equVol;
                  Preset.saveCustomBatteryOptions(widget.batteryOption);
                });
              }
            },
          ),
          ParamRow(
            label: Constants.bulkDurationParam.title,
            value: widget.batteryOption.bulkDuration,
            param: Constants.bulkDurationParam,
            backgroundColor: Color(0xFFD7FFFF),
            enabled: _isEnabled(),
            onPressed: () async {
              var ret = await showSpinDialog(
                context: context,
                param: Constants.bulkDurationParam,
                value: widget.batteryOption.bulkDuration.toDouble(),
              );
              if (ret != null) {
                setState(() {
                  widget.batteryOption.bulkDuration = ret.toInt();
                  Ble.instance.customBatteryOption.bulkDuration = widget.batteryOption.bulkDuration;
                  Preset.saveCustomBatteryOptions(widget.batteryOption);
                });
              }
            },
          ),
          ParamRow(
            label: Constants.bulkVoltageParam.title,
            value: widget.batteryOption.bulkVol * scale,
            param: Constants.bulkVoltageParam,
            enabled: _isEnabled(),
            onPressed: () async {
              var ret = await showSpinDialog(
                context: context,
                param: Constants.bulkVoltageParam,
                value: widget.batteryOption.bulkVol,
                scale: scale,
              );
              if (ret != null) {
                setState(() {
                  widget.batteryOption.bulkVol = ret;
                  Ble.instance.customBatteryOption.bulkVol = widget.batteryOption.bulkVol;
                  Preset.saveCustomBatteryOptions(widget.batteryOption);
                });
              }
            },
          ),
          ParamRow(
            label: Constants.bulkReturnVoltageParam.title,
            value: widget.batteryOption.bulkResumeVol * scale,
            param: Constants.bulkReturnVoltageParam,
            backgroundColor: Color(0xFFD7FFFF),
            enabled: _isEnabled(),
            onPressed: () async {
              var ret = await showSpinDialog(
                context: context,
                param: Constants.bulkReturnVoltageParam,
                value: widget.batteryOption.bulkResumeVol,
                scale: scale,
              );
              if (ret != null) {
                setState(() {
                  widget.batteryOption.bulkResumeVol = ret;
                  Ble.instance.customBatteryOption.bulkResumeVol = widget.batteryOption.bulkResumeVol;
                  Preset.saveCustomBatteryOptions(widget.batteryOption);
                });
              }
            },
          ),
          ParamRow(
            label: Constants.floatVoltageParam.title,
            value: widget.batteryOption.floatVol * scale,
            param: Constants.floatVoltageParam,
            enabled: _isEnabled(),
            onPressed: () async {
              var ret = await showSpinDialog(
                context: context,
                param: Constants.floatVoltageParam,
                value: widget.batteryOption.floatVol,
                scale: scale,
              );
              if (ret != null) {
                setState(() {
                  widget.batteryOption.floatVol = ret;
                  Ble.instance.customBatteryOption.floatVol = widget.batteryOption.floatVol;
                  Preset.saveCustomBatteryOptions(widget.batteryOption);
                });
              }
            },
          ),
          ParamRow(
            label: Constants.lowDisconnectVoltageParam.title,
            value: widget.batteryOption.lvdVol * scale,
            param: Constants.lowDisconnectVoltageParam,
            backgroundColor: Color(0xFFD7FFFF),
            enabled: _isEnabled(),
            onPressed: () async {
              var ret = await showSpinDialog(
                context: context,
                param: Constants.lowDisconnectVoltageParam,
                value: widget.batteryOption.lvdVol,
                scale: scale,
              );
              if (ret != null) {
                setState(() {
                  widget.batteryOption.lvdVol = ret;
                  Ble.instance.customBatteryOption.lvdVol = widget.batteryOption.lvdVol;
                  Preset.saveCustomBatteryOptions(widget.batteryOption);
                });
              }
            },
          ),
          ParamRow(
            label: Constants.lowResumeVoltageParam.title,
            value: widget.batteryOption.lvdResumeVol * scale,
            param: Constants.lowResumeVoltageParam,
            enabled: _isEnabled(),
            onPressed: () async {
              var ret = await showSpinDialog(
                context: context,
                param: Constants.lowResumeVoltageParam,
                value: widget.batteryOption.lvdResumeVol,
                scale: scale,
              );
              if (ret != null) {
                setState(() {
                  widget.batteryOption.lvdResumeVol = ret;
                  Ble.instance.customBatteryOption.lvdResumeVol = widget.batteryOption.lvdResumeVol;
                  Preset.saveCustomBatteryOptions(widget.batteryOption);
                });
              }
            },
          ),
        ],
    );
  }
}

class ParamRow extends StatelessWidget {
  const ParamRow({
    Key? key,
    required this.label,
    this.value,
    required this.param,
    this.labelColor,
    this.backgroundColor,
    this.enabled,
    required this.onPressed,
    this.onLongPress,
  }) : super(key: key);

  final String label;
  final num? value;
  final Param param;
  final Color? labelColor;
  final Color? backgroundColor;
  final bool? enabled;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
      color: backgroundColor,
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(color: labelColor),),),
          Container(
            height: 40,
            constraints: const BoxConstraints(
              minWidth: 60,
            ),
            child: OutlinedButton(
              onPressed: (enabled == null || enabled == true) ? onPressed : null,
              child: Text(value?.toStringAsFixed(param.decimals) ?? ''),
              style: OutlinedButton.styleFrom(
                primary: Colors.black,
                padding: const EdgeInsets.all(0),
                textStyle: const TextStyle(
                  fontSize: 16,
                )
              ),
            ),
          ),
          Container(
            constraints: const BoxConstraints(
              minWidth: 32,
            ),
            padding: const EdgeInsets.fromLTRB(6, 0, 0, 0),
            child: Text(param.unit ?? ''),
          )
        ],
      ),
    );
  }
}
