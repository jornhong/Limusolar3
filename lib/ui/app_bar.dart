import 'package:flutter/material.dart';
import 'ble_dialog.dart';
import '../ble.dart';
class MyAppBar extends AppBar {
  MyAppBar(BuildContext context, String? title, {Key? key}) : super(key: key,
      title: Text(title ?? ''),
      centerTitle: true,
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
      actions: <Widget>[
        IconButton(
            icon: StreamBuilder<DeviceState>(
              initialData: Ble.instance.currentDeviceState,
              stream: Ble.instance.deviceState,
              builder: (c, snapshot) {
                if (snapshot.data == DeviceState.authorized) {
                  return const Icon(Icons.bluetooth_connected);
                } else {
                  return const Icon(Icons.bluetooth_disabled);
                }
              } ,
            ),
            onPressed: () {
              blueIconClick(context);
            }
        ),
      ]
  );
}