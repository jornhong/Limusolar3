import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pvl/generated/l10n.dart';

enum DoorAction {open, close}

class Door extends StatefulWidget {
  const Door({Key? key, this.action, this.onPressed}) : super(key: key);
  final DoorAction? action;
  final VoidCallback? onPressed;

  @override
  _DoorState createState() => _DoorState();
}

class _DoorState extends State<Door> with SingleTickerProviderStateMixin {
  final Tween<double> _lineTween = Tween(begin: 0.0, end: 1.0);
  late Animation<double> _buttonAnimation;
  late Animation<double> _lineAnimation;
  late Animation<double> _doorAnimation;
  late AnimationController _controller;

  void startAnimation() {
    _controller.forward();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: Duration(milliseconds: 1000), vsync: this);
    _buttonAnimation = _lineTween.animate(CurveTween(curve: Interval(0.0, 0.3, curve: Curves.easeInOut)).animate(_controller));
    _lineAnimation = _lineTween.animate(CurveTween(curve: Interval(0.3, 0.6, curve: Curves.easeInOut)).animate(_controller));
    _doorAnimation = _lineTween.animate(CurveTween(curve: Interval(0.6, 1.0, curve: Curves.easeInOut)).animate(_controller));

    _buttonAnimation.addListener(() {setState(()=>{});});
    _lineAnimation.addListener(() {setState(()=>{});});

    // _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _doorAnimation.addListener(() {setState(()=>{});});
    _doorAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.stop();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant Door oldWidget) {
    switch(widget.action) {
      case DoorAction.open:
        _controller.forward();
        break;
      case DoorAction.close:
        _controller.reverse();
        break;
      default:
        break;
    }
    super.didUpdateWidget(oldWidget);
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: FractionallySizedBox(
                alignment: Alignment.topCenter,
                widthFactor: 1,
                heightFactor: 1 - _doorAnimation.value,
                child: Container(
                  color: Color(0x99000000),
                ),
              ),
            ),
            Expanded(
              child: FractionallySizedBox(
                alignment: Alignment.bottomCenter,
                widthFactor: 1,
                heightFactor: 1 - _doorAnimation.value,
                child: Container(
                  color: Color(0x99000000),
                ),
              ),
            ),
          ],
        ),
        Center(
          child: SizedBox(
            height: 0.8,
            child: FractionallySizedBox(
              alignment: Alignment.topCenter,
              widthFactor: 1.0 - _lineAnimation.value,
              heightFactor: 1,
              child: Container(
                color: Color(0x99FFFFFF),
              ),
            ),
          ),
        ),
        Center(
          child: Opacity(
            opacity: 1.0 - _buttonAnimation.value,
            child: ElevatedButton(
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 15, horizontal: 18)),
                  textStyle: MaterialStateProperty.all(TextStyle(fontSize: 16)),
                  backgroundColor: MaterialStateProperty.resolveWith((states) {
                    if (states.contains(MaterialState.pressed)) {
                      return Colors.blue[200];
                    }
                    return Colors.white;
                  }),
                ),
                child: Text(S.of(context).Connect),
                onPressed: () {
                  if (widget.onPressed != null) {
                    widget.onPressed!();
                  }
                }
            ),
          ),
        )
      ],
    );
  }
}
