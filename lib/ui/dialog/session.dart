import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pvl/generated/l10n.dart';
import 'package:pvl/model.dart';
import 'common.dart';
import '../../ble.dart';

void showSessionDialog(BuildContext context) {
  showDialog(
    barrierDismissible: true,
    context: context,
    builder: (context) => SessionDialog(),
  );
}
class SessionDialog extends StatefulWidget {
  const SessionDialog({Key? key}) : super(key: key);

  @override
  _SessionDialogState createState() => _SessionDialogState();
}

class _SessionDialogState extends State<SessionDialog> {

  late Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String title = Ble.instance.currentDevice?.name ?? '';
    return AlertDialog (
      clipBehavior: Clip.antiAliasWithSaveLayer,
      contentPadding: EdgeInsets.zero,
      title: DialogTitle(title: S.of(context).Bluetooth_Connected),
      titlePadding: EdgeInsets.zero,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            // width: MediaQuery.of(context).size.width*0.8,
            // height: 280.0,
            constraints: BoxConstraints(
              minWidth: 320,
            ),
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
            child: Consumer<BleSession>(builder: (ctx, session, child) {
              var diff = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(session.time));
              int length = DateTime.now().millisecondsSinceEpoch - session.time;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _getRow('${S.of(context).Session}:', title),
                  _getRow('${S.of(context).Length}:', session.formatMSecToTimeFormat(length)),
                  _getRow('${S.of(context).Tx}:', '${session.txBytes} bytes / ${session.txFrames} frames'),
                  _getRow('${S.of(context).Rx}:', '${session.rxBytes} bytes / ${session.rxFrames} frames'),
                  _getRow('${S.of(context).Rx_Error}:', '${session.rxErrors} frames'),
                  _getRow('${S.of(context).Tx_Error}:', '${session.txErrors} frames'),
                ],
              );
            }),
          ),
          TwoActionsBar(
            onLeftPressed: () =>
                Navigator.of(context, rootNavigator: true).pop(),
            rightText: S.of(context).DISCONNECT,
            onRightPressed: () {
              Ble.instance.disconnect();
              Navigator.of(context, rootNavigator: true).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget _getRow(String label, String? value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          constraints: const BoxConstraints(
            minWidth: 80,
          ),
          child: Text(label,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
        Text(value ?? ''),
      ],
    );
  }
}
