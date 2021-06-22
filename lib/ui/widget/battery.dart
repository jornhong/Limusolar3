import 'dart:async';
import 'package:flutter/material.dart';

class DryBatteryLevel extends StatefulWidget {
  const DryBatteryLevel({Key? key,
    this.label,
    required this.level,
    required this.charging,
    required this.enabled,}) : super(key: key);

  final String? label;
  final int level;
  final bool charging;
  final bool enabled;

  @override
  _DryBatteryLevelState createState() => _DryBatteryLevelState();
}

class _DryBatteryLevelState extends State<DryBatteryLevel> {
  final lineMargin = EdgeInsets.fromLTRB(8, 2, 8, 2);
  late Timer timer;
  bool tickToggle = false;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      if ((widget.charging || widget.level == 0) && widget.enabled) {
        setState(() {
          tickToggle = !tickToggle;
        });
      } else {
        if (tickToggle != false) {
          setState(() {
            tickToggle = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color textColor = Colors.white;
    // if (widget.charging && widget.enabled) {
    //   textColor = Colors.lightGreenAccent;
    // } else {
    //   textColor = Colors.white;
    // }
    return Stack(
      children: [
        Image.asset('assets/images/dry_battery_frame.png',
          width: 80.0,
          height: 120.0,
          fit: BoxFit.fill,
        ),
        Positioned(
          top: 8.0,
          left: 0,
          right: 0,
          child: Text(widget.label ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(color: textColor),
          ),
        ),
        Positioned(
          top: 28.0,
          left: 0.0,
          bottom: 6.0,
          right: 0.0,
          child: Column(
            children: [
              DryBatteryLine(position: 4, level: widget.level, margin: lineMargin, tickToggle: tickToggle),
              DryBatteryLine(position: 3, level: widget.level, margin: lineMargin, tickToggle: tickToggle),
              DryBatteryLine(position: 2, level: widget.level, margin: lineMargin, tickToggle: tickToggle),
              DryBatteryLine(position: 1, level: widget.level, margin: lineMargin, tickToggle: tickToggle),
            ],
          ),
        ),
        // Positioned(
        //   top: 28.0,
        //   left: 0.0,
        //   bottom: 6.0,
        //   right: 0.0,
        //   child: Visibility(
        //     visible: widget.charging,
        //     child: Image.asset('assets/images/charging.png', color: Colors.lightGreenAccent, scale: 2,),
        //   ),
        // ),
      ],
    );
  }

}

class DryBatteryLine extends StatelessWidget {
  const DryBatteryLine({Key? key, required this.position, required this.level, this.margin, required this.tickToggle}) : super(key: key);
  final int position;
  final int level;
  final EdgeInsetsGeometry? margin;
  final bool tickToggle;
  @override
  Widget build(BuildContext context) {
    var visible = position <= level || ((position == 1 && level == 0) & tickToggle);
    return Expanded(
      child: Visibility(
        visible: visible,
        child: Container(
          margin: margin,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(6.0)),
          ),
        ),
      )
    );
  }
}

class DryBatteryLevelHorizontal extends StatefulWidget {
  const DryBatteryLevelHorizontal({Key? key,
    required this.level,
    required this.charging,
    required this.enabled,
  }) : super(key: key);

  final int level;
  final bool charging;
  final bool enabled;

  @override
  _DryBatteryLevelHorizontalState createState() => _DryBatteryLevelHorizontalState();
}

class _DryBatteryLevelHorizontalState extends State<DryBatteryLevelHorizontal> {
  static const lineMargin = EdgeInsets.symmetric(vertical: 2, horizontal: 1.5);
  Timer? timer;
  bool tickToggle = false;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      if ((widget.charging || widget.level == 0) && widget.enabled) {
        setState(() {
          tickToggle = !tickToggle;
        });
      } else {
        if (tickToggle != false) {
          setState(() {
            tickToggle = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // print('level: ${widget.level} charging: ${widget.charging}');
    return Stack(
      children: [
        Positioned(child: Image.asset('assets/images/battery_h_frame.png')),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          bottom: 0,
          child: Container(
            padding: EdgeInsets.fromLTRB(3, 1, 7, 1),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _getInd(_isVisible(1), lineMargin),
                _getInd(_isVisible(2), lineMargin),
                _getInd(_isVisible(3), lineMargin),
                _getInd(_isVisible(4), lineMargin),
              ],
            ),
          ),
        ),
      ],
    );
  }

  bool _isVisible(int i) {
    return i <= widget.level || ((i == 1 && widget.level == 0) & tickToggle);
  }

  Widget _getInd(bool visible, EdgeInsetsGeometry? margin) {
    if (visible == true) {
      return Expanded(
          child: Container(
            margin: margin,
            decoration: new BoxDecoration(
              color: Colors.cyanAccent,
              borderRadius: BorderRadius.all(Radius.circular(2.0)),
            ),
          )
      );
    } else {
      return Expanded(
        child: Container(),
      );
    }
  }

}

class BatteryLevel extends StatefulWidget {
  const BatteryLevel({Key? key, this.label, required this.level, required this.charging, required this.enabled, this.innerPadding}) : super(key: key);

  final String? label;
  final int level;
  final bool charging;
  final bool enabled;
  final EdgeInsetsGeometry? innerPadding;

  @override
  _BatteryLevelState createState() => _BatteryLevelState();
}

class _BatteryLevelState extends State<BatteryLevel> {
  final lineMargin = EdgeInsets.fromLTRB(4, 1, 4, 1);
  Timer? timer;
  bool tickToggle = false;
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      if ((widget.charging || widget.level == 0) && widget.enabled) {
        setState(() {
          tickToggle = !tickToggle;
        });
      } else {
        if (tickToggle != false) {
          setState(() {
            tickToggle = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset('assets/images/battery_frame.png',
          fit: BoxFit.fill,
        ),
        Positioned(
          top: 8.0,
          left: 0,
          right: 0,
          child: Text(widget.label ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
        ),
        Positioned(
            top: 9.0,
            left: 0,
            bottom: 3.0,
            right: 0.0,
            child: Column(
              children: [
                _getInd(_isVisible(4), lineMargin),
                _getInd(_isVisible(3), lineMargin),
                _getInd(_isVisible(2), lineMargin),
                _getInd(_isVisible(1), lineMargin),
              ],
            )
        ),
      ],
    );
  }

  bool _isVisible(int i) {
    return i <= widget.level || ((i == 1 && widget.level == 0) & tickToggle);
  }

  Widget _getInd(bool visible, EdgeInsetsGeometry? margin) {
    if (visible == true) {
      return Expanded(
          child: Container(
            margin: margin,
            decoration: new BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(2.0)),
            ),
          )
      );
    } else {
      return Expanded(
        child: Container(),
      );
    }
  }

}
