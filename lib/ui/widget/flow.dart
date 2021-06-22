import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum FlowPoint {none, from, to, all}

class LinearFlow extends StatefulWidget {
  LinearFlow({
    Key? key,
    this.from,
    this.to,
    this.point,
    this.isActive = false,
  }) : super(key: key);

  final Offset? from;
  final Offset? to;
  final FlowPoint? point;
  final bool isActive;

  @override
  _LinearFlowState createState() => _LinearFlowState();
}

class _LinearFlowState extends State<LinearFlow>
    with SingleTickerProviderStateMixin {
  final GlobalKey _rootKey = GlobalKey();
  late AnimationController _controller;
  late Animation _animation;
  final Path _path = Path();
  double _fraction = -1;
  PathMetric? _pm;

  void _getSize() {
    if (widget.from == null || widget.to == null) {
      return;
    }

    double fromDx = widget.from!.dx;
    double fromDy = widget.from!.dy;
    double toDx = widget.to!.dx;
    double toDy = widget.to!.dy;

    double midX = fromDx + (toDx - fromDx) / 2.0;
    _path.reset();
    _path.moveTo(fromDx, fromDy);
    _path.lineTo(midX, fromDy);
    _path.lineTo(midX, toDy);
    _path.lineTo(toDx, toDy);

    PathMetrics pms = _path.computeMetrics();
    try {
      _pm = pms.elementAt(0);
    } catch(e) {
      print(e);
    }
  }

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    // WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
    //   _startAnimation();
    // });
    super.initState();
    _getSize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant LinearFlow oldWidget) {
    if (_pm == null) {
      _getSize();
    }
    if (widget.isActive) {
      _startAnimation();
    } else {
      _controller.stop();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      key: _rootKey,
      painter: LinearFlowPainter(_path, _pm, _fraction, _controller.isAnimating, from: widget.from, to: widget.to, point: widget.point),
    );
  }

  _startAnimation() {
    // RenderBox renderBox = _canvasKey.currentContext.findRenderObject();
    // Size s = renderBox.size;
    if (_pm == null) {
      return;
    }

    double len = _pm!.length;

    _animation = Tween(begin: 0.0, end: len).animate(_controller)
      ..addListener(() {
        setState(() {
          _fraction = _animation.value;
        });
      })
      ..addStatusListener((status){
        if (status == AnimationStatus.completed) {
          // _controller.stop();
        }
      });

    // _controller.forward();
    _controller.repeat();
  }
}

class LinearFlowPainter extends CustomPainter {
  LinearFlowPainter(this._path, this._pm, this._fraction, this._isAnimating, {this.from, this.to, this.point});

  final Offset? from;
  final Offset? to;
  final FlowPoint? point;
  final PathMetric? _pm;
  final double _fraction;
  final Path _path;
  final bool _isAnimating;
  final Paint linePaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.square
    ..strokeJoin = StrokeJoin.round
    ..strokeWidth = 6.0
    ..isAntiAlias = true;

  final Paint pointPaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..strokeWidth = 12.0
    ..isAntiAlias = true;

  final Paint animPaint = Paint()
    ..color = Colors.black26
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..strokeWidth = 6.0
    ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Size size) {
    // double fromDx = from == null ? 0 : from!.dx;
    // double fromDy = from == null ? 0 : from!.dy;
    // double toDx = from == null ? size.width : to!.dx;
    // double toDy = from == null ? size.height : to!.dy;
    //
    // print("flow of fromDx: $fromDx fromDy: $fromDy");
    //
    // double midX = fromDx + (toDx - fromDx) / 2.0;
    // path.reset();
    // path.moveTo(fromDx, fromDy);
    // path.lineTo(midX, fromDy);
    // path.lineTo(midX, toDy);
    // path.lineTo(toDx, toDy);
    canvas.drawPath(_path, linePaint);

    if (_pm == null) {
      return;
    }
    Tangent? fromTangent = _pm!.getTangentForOffset(0);
    Tangent? toTangent = _pm!.getTangentForOffset(_pm!.length - 1);
    Offset? from = fromTangent?.position;
    Offset? to = toTangent?.position;
    double fromDx = from?.dx ?? 0;
    double fromDy = from?.dy ?? 0;
    double toDx = to?.dx ?? 0;
    double toDy = to?.dy ?? 0;

    switch (point) {
      case FlowPoint.from:
        canvas.drawPoints(PointMode.points, [Offset(fromDx, fromDy)], pointPaint);
        break;
      case FlowPoint.to:
        canvas.drawPoints(PointMode.points, [Offset(toDx, toDy)], pointPaint);
        break;
      case FlowPoint.all:
        canvas.drawPoints(PointMode.points, [Offset(fromDx, fromDy)], pointPaint);
        canvas.drawPoints(PointMode.points, [Offset(toDx, toDy)], pointPaint);
        break;
      default:
        break;
    }

    if (_isAnimating) {
      var step = _pm!.length / 8.0;
      for (int i = 0; i < 8; i++) {
        Tangent? animTangent = _pm!.getTangentForOffset(i * step + _fraction / 8);
        if (animTangent != null) {
          Offset animPoint = animTangent.position;
          if (i < animPoints.length) {
            animPoints[i] = animPoint;
          } else {
            animPoints.add(animPoint);
          }
        }
      }
      canvas.drawPoints(PointMode.points, animPoints, animPaint);
    }
  }

  List<Offset> animPoints = [];

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

}