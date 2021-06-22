import 'package:flutter/material.dart';

int rssiToStep(int rssi) {
  if (rssi == 0) {
    return 0;
  } else if (rssi >= -40) {
    return 5;
  } else if (rssi >= -50) {
    return 4;
  } else if (rssi >= -60) {
    return 3;
  } else if (rssi >= -70) {
    return 2;
  } else if (rssi >= -90) {
    return 1;
  }
  return 0;
}

final rssiImages = [
  Image.asset(
    'assets/images/ic_signal_0.png',
    color: Colors.cyan,
    width: 20,
  ),
  Image.asset(
    'assets/images/ic_signal_1.png',
    color: Colors.cyan,
    width: 20,
  ),
  Image.asset(
    'assets/images/ic_signal_2.png',
    color: Colors.cyan,
    width: 20,
  ),
  Image.asset(
    'assets/images/ic_signal_3.png',
    color: Colors.cyan,
    width: 20,
  ),
  Image.asset(
    'assets/images/ic_signal_4.png',
    color: Colors.cyan,
    width: 20,
  ),
  Image.asset(
    'assets/images/ic_signal_5.png',
    color: Colors.cyan,
    width: 20,
  ),
];

class Signal extends StatelessWidget {
  const Signal({Key? key, required this.rssi}) : super(key: key);
  final int rssi;

  @override
  Widget build(BuildContext context) {
    var level = rssiToStep(rssi);
    // print('rssi: $rssi level: $level');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        rssiImages[level],
        Text(
          rssi.toString(),
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }
}
