import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprintf/sprintf.dart';
import 'package:pvl/generated/l10n.dart';
import '../../model.dart';

class ActiveMonitorDetail extends StatelessWidget {
  static const Divider _divider = Divider(height: 1.0, color: Color(0xFF00DDDD));

  const ActiveMonitorDetail({Key? key}) : super(key: key);

  static const TextStyle _titleTextStyle = TextStyle(
    fontSize: 16,
    color: Colors.cyan,
  );
  static const TextStyle _summaryTextStyle = TextStyle(
    fontSize: 16,
    color: Colors.white,
    height: 2.0,
  );

  @override
  Widget build(BuildContext context) {
    return Consumer<DeviceStatus>(builder: (ctx, status, child) {
      String scValue;
      if (status.chargeCurrent < 0.2) {
        scValue = sprintf('%.02fV       <%.02fA       <%.02fW', [status.pvVol, 0.2, 2.0]);
      } else {
        scValue = sprintf('%.02fV       %.02fA       %.02fW', [status.pvVol, status.chargeCurrent, status.pvVol * status.chargeCurrent]);
      }

      String b1Value = sprintf('%.02fV       %.02fA', [status.battery1Vol, status.battery1ChargeCurrent]);
      Color b1StageColor;
      if(status.battery1ChargeEnabled) {
        b1StageColor = Colors.white;
      } else {
        b1StageColor = Color(0xFF333333);
      }

      String b2Value = sprintf('%.02fV       %.02fA', [status.battery2Vol, status.battery2ChargeCurrent]);
      Color b2StageColor;
      if(status.battery2ChargeEnabled) {
        b2StageColor = Colors.white;
      } else {
        b2StageColor = Color(0xFF333333);
      }

      String chargeValue = status.chargeDuty.toString();

      if(status.battery1ChargeEnabled) {
        if((status.pvVol - status.battery1Vol) > 0.5) {
          chargeValue = S.of(context).Available;
        } else {
          chargeValue = S.of(context).Not_Available;
        }
      }

      if(status.battery2ChargeEnabled) {
        if((status.pvVol - status.battery2Vol) > 0.5) {
          chargeValue = S.of(context).Available;
        } else {
          chargeValue = S.of(context).Not_Available;
        }
      }

      return ListView(
          children: <Widget>[
            ListTile(
              leading: Image.asset('assets/images/solar_cells.png', width: 38.0),
              title: Text(S.of(context).Solar_Cells, style: _titleTextStyle),
              subtitle: Text(scValue, style: _summaryTextStyle),
            ),
            _divider,
            ListTile(
              leading: Image.asset('assets/images/battery_ind.png', width: 36.0),
              title: Text('${S.of(context).Battery}(1)', style: _titleTextStyle),
              subtitle: Row(
                children: [
                  Text(b1Value, style: _summaryTextStyle),
                  const SizedBox(width: 30,),
                  Text(DeviceStatus.chargeModeText(status.battery1ChargeMode), style: _summaryTextStyle.copyWith(
                    color: b1StageColor,
                  )),
                ],
              ),
            ),
            _divider,
            ListTile(
              leading: Image.asset('assets/images/battery_ind.png', width: 36.0),
              title: Text('${S.of(context).Battery}(2)', style: _titleTextStyle),
              subtitle: Row(
                children: [
                  Text(b2Value, style: _summaryTextStyle),
                  const SizedBox(width: 30,),
                  Text(DeviceStatus.chargeModeText(status.battery1ChargeMode), style: _summaryTextStyle.copyWith(
                    color: b2StageColor,
                  )),
                ],
              ),
            ),
            _divider,
            ListTile(
              leading: Image.asset('assets/images/charging_ind.png', width: 38.0),
              title: Text(S.of(context).Charge, style: _titleTextStyle),
              subtitle: Text(chargeValue, style: _summaryTextStyle),
            ),
            _divider,
          ]
      );
    });
  }
}
