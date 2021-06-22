import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprintf/sprintf.dart';
import 'package:pvl/generated/l10n.dart';
import '../../model.dart';

class ActiveMonitorInfo extends StatelessWidget {
  const ActiveMonitorInfo({Key? key}) : super(key: key);
  static const Divider _infoDivider = Divider(height: 7.0, color: Color(0xFF00DDDD));
  static const TextStyle _titleTextStyle = TextStyle(
    fontSize: 16,
    color: Colors.cyan,
  );
  static const TextStyle _valueTextStyle = TextStyle(
    fontSize: 16,
    color: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    return Consumer<SystemInfo>(builder: (ctx, info, child) {
      int hour = (info.deviceTime / 3600).floor();
      int minute = ((info . deviceTime / 60) % 60).floor();
      int second = (info.deviceTime % 60).floor();
      // var deviceTime = '$hour:$minute:$second';
      var deviceTime = sprintf("%02d:%02d:%02d", [hour, minute, second]);
      return ListView(
        children: <Widget>[
          _getInfoRow('${S.of(context).Unique_ID}:', info.uniqueID),
          _getInfoRow('${S.of(context).Modal}:', info.modal),
          _infoDivider,
          _getInfoRow('${S.of(context).Serial_Number}:', info.hwPlatform),
          _getInfoRow('${S.of(context).Hw_Version}:', info.hardwareVersion),
          _infoDivider,
          _getInfoRow('${S.of(context).Software_Platform}:', 'N/A'),
          _getInfoRow('${S.of(context).Software_Version}:', info.softwareVersion),
          _infoDivider,
          _getInfoRow('${S.of(context).Manufacturer}:', info.manufactureCode.toString()),
          _getInfoRow('${S.of(context).Page}:', 'N/A'),
          _infoDivider,
          _getInfoRow('${S.of(context).Boot_Time_Length}:', deviceTime),
          _infoDivider,
        ],
      );
    });
  }

  Widget _getInfoRow(String label, String? value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: _titleTextStyle),
          Text(value ?? 'N/A', style: _valueTextStyle),
        ],
      ),
    );
  }
}
