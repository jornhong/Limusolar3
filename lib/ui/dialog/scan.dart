import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:pvl/generated/l10n.dart';
import 'package:pvl/ui/dialog/common.dart';
import 'package:pvl/ui/widget/signal.dart';
import '../../ble.dart';

Future<BluetoothDevice?> showScanDialog(BuildContext context) {
  return showDialog<BluetoothDevice>(
    barrierDismissible: true,
    context: context,
    builder: (context) => ScanDialog(),
  );
}

class ScanDialog extends StatelessWidget {
  const ScanDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Container(
        color: Colors.cyan,
        padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              S.of(context).Scanning_devices,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
              ),
            ),
            const SpinKitFadingCircle(color: Colors.white, size: 32.0),
          ],
        ),
      ),
      titlePadding: EdgeInsets.zero,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      contentPadding: EdgeInsets.zero,
      content: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 320.0,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: StreamBuilder<List<ScanResult>>(
                  stream: Ble.instance.scanResults,
                  initialData: [],
                  builder: (c, snapshot) => Column(
                    children: snapshot.data!
                        .map(
                          (r) => ScanResultTile(
                            result: r,
                            onTap: () {
                              Navigator.of(context, rootNavigator: true)
                                  .pop(r.device);
                            },
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
            OneActionBar(
              text: S.of(context).CANCEL,
            ),
          ],
        ),
      ),
    );
  }
}

class ScanResultTile extends StatelessWidget {
  const ScanResultTile({Key? key, required this.result, this.onTap})
      : super(key: key);
  final ScanResult result;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final String id;
    if (Platform.isIOS) {
      id = '';
    } else {
      id = result.device.id.id;
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          leading: Signal(rssi: result.rssi),
          minLeadingWidth: 24,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(result.device.name),
              Text(
                id,
                style: const TextStyle(color: Color(0xFF6D6D6D), fontSize: 12.0),
              ),
            ],
          ),
          onTap: onTap,
        ),
        const Divider(
          height: 1,
          color: Colors.cyan,
        ),
      ],
    );
  }
}
