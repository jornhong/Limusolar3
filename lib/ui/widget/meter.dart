import 'dart:ui' as dui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'battery.dart';

class BatteryMeter extends StatelessWidget {
  const BatteryMeter({Key? key, this.label, this.value, required this.maxValue,
    required this.frameRadius, required this.charging, required this.enabled,
    required this.batteryLevel,
    required this.chargeCurrent,
    this.masterIndicaterColor, this.subIndicaterColor}) : super(key: key);

  final String? label;
  final double? value;
  final double maxValue;
  final double frameRadius;
  final bool charging;
  final bool enabled;
  final int batteryLevel;
  final double chargeCurrent;
  final Color? masterIndicaterColor;
  final Color? subIndicaterColor;

  @override
  Widget build(BuildContext context) {
    var currentText = ((chargeCurrent <= 0.2) && (chargeCurrent > 0)) ? "< ${chargeCurrent.toStringAsFixed(2)}A" : "${chargeCurrent.toStringAsFixed(2)}A";
    var voltageText = '${value?.toStringAsFixed(2) ?? '0.00'}V';
    return Stack(
      children: [
        Positioned(
          child: Center(
            child: CustomPaint(
              painter: BatteryMeterPainter(
                value: value,
                maxValue: maxValue,
                frameRadius: frameRadius,
                masterIndicaterColor: masterIndicaterColor,
                subIndicaterColor: subIndicaterColor,
              ),
              child: Container(),
            ),
          ),
        ),
        Positioned(
          top: 0,
          bottom: 0,
          left: 0,
          right: 0,
          child: Center(
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 0.5,
              child: Image.asset('assets/images/center_glass_effect.png',),
            ),
          ),
        ),
        Positioned(
          top: 0,
          bottom: 0,
          left: 0,
          right: 0,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(currentText,
                  style: TextStyle(
                      color: Color(0xFF69E6E6),
                      fontSize: frameRadius * 0.15,
                      fontWeight: FontWeight.bold,
                  ),
                ),
                Center(
                  child: FractionallySizedBox(
                    widthFactor: 0.3,
                    child: Divider(color: Color(0xFF69E6E6), thickness: 1.2, height: frameRadius * 0.2 * 0.15 * 2 + 6,),
                  ),
                ),
                Text(voltageText,
                  style: TextStyle(
                    color: Color(0xFF69E6E6),
                    fontSize: frameRadius * 0.15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: frameRadius * 0.2 * 0.15,),
                // SizedBox(height: 4,),
                FractionallySizedBox(
                  widthFactor: 0.25,
                  child: DryBatteryLevelHorizontal(
                    level: batteryLevel,
                    charging: charging,
                    enabled: enabled && (value ?? 0) > 0,
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  // child: Image.asset(
                  //   'assets/images/lighter_mask_effect.png',
                  //   fit: BoxFit.fill,
                  //   width:(frameRadius - 8) * 2,
                  //   height:(frameRadius - 8) - frameRadius * 0.1,
                  // ),
                ),
              ),
              Expanded(
                child: Container(
                  child: Center(
                    child: Text(label ?? '',
                      style: TextStyle(
                        color: Color(0xFF69E6E6),
                        fontSize: frameRadius * 0.15,
                        fontWeight: FontWeight.bold,
                        shadows: <Shadow>[
                          Shadow(
                          offset: Offset(0.1, 0.1),
                          blurRadius: 15.0,
                          color: Color(0xFF69E6E6),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class BatteryMeterPainter extends CustomPainter {

  final Path tickMarkPath = Path();
  final Path tickMark5Path = Path();
  final Path tickMarkActivePath = Path();
  final math.Point<double> canvasCenter = math.Point(0.0, 0.0);

  Paint tickMarkPaint = Paint()..color = Colors.blue
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0
    ..strokeCap = StrokeCap.round
    ..isAntiAlias = true;

  Paint tickMark5Paint = Paint()..color = Colors.blue
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3.0
    ..strokeCap = StrokeCap.round
    ..isAntiAlias = true;

  final Paint tickMarkActivePaint = Paint()
    ..color = Color(0x8007D0F9)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0
    ..strokeCap = StrokeCap.round
    ..maskFilter = MaskFilter.blur(BlurStyle.normal, 30)
    ..isAntiAlias = true;

  BatteryMeterPainter({
    double? value,
    required this.maxValue,
    required this.frameRadius,
    Color? masterIndicaterColor,
    Color? subIndicaterColor,
    this.tickMarkColor = Colors.grey,
    this.tickMarkBoldColor = Colors.cyan,
    }) {
      tickMark5Paint.color = masterIndicaterColor ?? Color(0xFF222222);
      tickMarkPaint.color = subIndicaterColor ?? Color(0xFFFF0000);
      this.value = value ?? 0;
      tickMarkActivePaint.strokeWidth = frameRadius / 5.5;
    }

  late double value;
  final double maxValue;
  final double frameRadius;
  final double startAngle = math.pi * (140 / 180);
  final Color tickMarkColor;
  final Color tickMarkBoldColor;

  double calcAngle(v){
    //return (value / maxValue)*(endAngle - startAngle);
    return ((260.0 / 360.0) * 2 * math.pi / maxValue) * v + startAngle;
  }

  final Paint pointerPaint = Paint()
    ..color = Colors.red
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3.0
    ..strokeCap = StrokeCap.round
    ..isAntiAlias = true;

  final pointerPath = Path();
  void drawPointer(Canvas canvas, Size size) {
    double frameRadius = math.min(size.width, size.height) / 2;
    double centerX = size.width / 2;
    double centerY = size.height / 2;

    var angle = calcAngle(value);
    var x = (frameRadius - (frameRadius / 5.5) - 4) * math.cos(angle) + centerX;
    var y = (frameRadius - (frameRadius / 5.5) - 4) * math.sin(angle) + centerY;
    pointerPath.reset();
    pointerPath.moveTo(centerX, centerY);
    pointerPath.lineTo(x, y);
    // canvas.drawLine(Offset(centerX, centerY), Offset(x, y), pointerPaint);
    canvas.drawPath(pointerPath, pointerPaint);
    // canvas.drawShadow(pointerPath, Colors.blue, 4, false);

    final Rect rect = Rect.fromCircle(center: Offset(centerX, centerY), radius: frameRadius - (frameRadius / 5.5 / 2));
    canvas.drawArc(rect, startAngle, angle - startAngle, false, tickMarkActivePaint);
  }

  void drawCanvasIndicater(Canvas canvas, Size size) {
    double frameRadius = math.min(size.width, size.height) / 2;
    double centerX = size.width / 2;
    double centerY = size.height / 2;

    frameRadius -= 1;//circlePaint.strokeWidth / 2;
    tickMarkPath.reset();
    tickMark5Path.reset();
    for(var i = 0; i < 45; i = i + 1) {
      var angle = calcAngle(i);
      var x = (frameRadius) * math.cos(angle) + centerX;
      var y = (frameRadius) * math.sin(angle) + centerY;
      if ((i % 5) == 0) {
        var x0 = (frameRadius - (frameRadius / 5.5)) * math.cos(angle) + centerX;
        var y0 = (frameRadius - (frameRadius / 5.5)) * math.sin(angle) + centerY;
        tickMark5Path.moveTo(x0, y0);
        tickMark5Path.lineTo(x, y);
      } else {
        var x0 = (frameRadius - (frameRadius / 5.5)) * math.cos(angle) + centerX;
        var y0 = (frameRadius - (frameRadius / 5.5)) * math.sin(angle) + centerY;
        tickMarkPath.moveTo(x0, y0);
        tickMarkPath.lineTo(x, y);
      }
    }
    canvas.drawPath(tickMarkPath, tickMarkPaint);
    canvas.drawPath(tickMark5Path, tickMark5Paint);
  }

  void canvasIndicaterActive(Canvas canvas, Size size) {
    double frameRadius = math.min(size.width, size.height) / 2;
    double centerX = size.width / 2;
    double centerY = size.height / 2;

    frameRadius -= circlePaint.strokeWidth / 2;

    tickMarkPath.reset();
    tickMark5Path.reset();
    tickMarkActivePath.reset();
    for(var i = 0; i < 45; i = i + 1) {
      var angle = calcAngle(i);
      var x = (frameRadius) * math.cos(angle) + centerX;
      var y = (frameRadius) * math.sin(angle) + centerY;
      if ((i % 5) == 0) {
        var x0 = (frameRadius - (frameRadius / 5.5)) * math.cos(angle) +
            centerX;
        var y0 = (frameRadius - (frameRadius / 5.5)) * math.sin(angle) +
            centerY;
        //ctx.strokeStyle = "#000000"
        if (value >= i) {
          x0 = (frameRadius - (frameRadius / 5.0)) * math.cos(angle) +
              centerX;
          y0 = (frameRadius - (frameRadius / 5.0)) * math.sin(angle) +
              centerY;
          tickMarkActivePath.moveTo(x0, y0);
          tickMarkActivePath.lineTo(x, y);
        } else {
          tickMark5Path.moveTo(x0, y0);
          tickMark5Path.lineTo(x, y);
        }
      } else {
        var x0 = (frameRadius - (frameRadius / 5.5)) * math.cos(angle) +
            centerX;
        var y0 = (frameRadius - (frameRadius / 5.5)) * math.sin(angle) +
            centerY;
        if (value >= i) {
          x0 = (frameRadius - (frameRadius / 5.0)) * math.cos(angle) +
              centerX;
          y0 = (frameRadius - (frameRadius / 5.0)) * math.sin(angle) +
              centerY;
          tickMarkActivePath.moveTo(x0, y0);
          tickMarkActivePath.lineTo(x, y);
        } else {
          tickMarkPath.moveTo(x0, y0);
          tickMarkPath.lineTo(x, y);
        }
      }
    }
    canvas.drawPath(tickMarkPath, tickMarkPaint);
    canvas.drawPath(tickMark5Path, tickMark5Paint);
    canvas.drawPath(tickMarkActivePath, tickMarkActivePaint);
  }

  Paint circlePaint = Paint()
    ..color = Color(0xFF808080)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0
    ..strokeCap = StrokeCap.round
    ..isAntiAlias = true;

  Paint canvas1Paint1 = Paint()
    ..color = Color(0xFF356B73)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0
    ..strokeCap = StrokeCap.round
    ..isAntiAlias = true;

  final outerCircleColor = Color(0xFF808080);
  final canvas1Filter = MaskFilter.blur(BlurStyle.outer, 10);
  final innerFilter = MaskFilter.blur(BlurStyle.inner, 5);
  final outerFilter = MaskFilter.blur(BlurStyle.outer, 10);

  void drawDial(Canvas canvas, Size size) {
    double frameRadius = math.min(size.width, size.height) / 2;
    double centerX = size.width / 2;
    double centerY = size.height / 2;

    circlePaint
      ..strokeWidth = 2
      ..color = outerCircleColor
      ..maskFilter = null;
    canvas.drawCircle(Offset(centerX, centerY), frameRadius, circlePaint);

    circlePaint
      ..strokeWidth = 2
      ..color = tickMarkBoldColor
      ..maskFilter = innerFilter;
    var innerCircleRadius = frameRadius / 2.0 + (frameRadius / 11.5 / 2.0) - 4;
    // canvas.drawCircle(Offset(centerX, centerY), innerCircleRadius - circlePaint.strokeWidth, circlePaint);

    circlePaint
      ..strokeWidth = frameRadius / 11.5
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;
    Rect rect1 = Rect.fromCircle(center: Offset(centerX, centerY), radius: innerCircleRadius);
    circlePaint.maskFilter = outerFilter;
    canvas.drawArc(rect1, calcAngle(0.0), (260.0 / 360.0) * 2 * math.pi, false, circlePaint);

    circlePaint
      ..maskFilter = MaskFilter.blur(BlurStyle.solid, 5)
      ..color = tickMarkBoldColor.withAlpha(96);
    canvas.drawArc(rect1, calcAngle(0.0), (260.0 / 360.0) * 2 * math.pi, false, circlePaint);
  }

  final glassPaint = Paint()
    ..color = Color(0x33FFFFFF)
    ..isAntiAlias = true;
  void drawGlass(Canvas canvas, Size size) {
    double frameRadius = math.min(size.width, size.height) / 2;
    double halfWidth = size.width / 2;
    double halfHeight = size.height / 2;

    final rect = Rect.fromLTRB(0.0, 0.0, size.width, halfHeight * 0.96);
    canvas.clipRect(rect);
    Rect rect1 = Rect.fromCircle(center: Offset(halfWidth, halfHeight), radius: frameRadius);
    canvas.drawArc(rect1, math.pi, math.pi, true, glassPaint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    drawCanvasIndicater(canvas, size);
    // canvasIndicaterActive(canvas, size);
    drawPointer(canvas, size);
    drawDial(canvas, size);
    drawGlass(canvas, size);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class PvMeter extends StatelessWidget {
  const PvMeter({
    Key? key,
    this.value,
    required this.maxValue,
    this.tickMarkColor = Colors.grey,
    this.tickMarkBoldColor = Colors.cyan,
  }) : super(key: key);

  final double? value;
  final double maxValue;
  final Color tickMarkColor;
  final Color tickMarkBoldColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          child: Center(
            child: CustomPaint(
              painter: PvMeterPainter(
                value: value,
                maxValue: maxValue,
                tickMarkColor: tickMarkColor,
              ),
              child: Container(),
            ),
          ),
        ),
        Positioned(
          child: Center(
            child: FractionallySizedBox(
              widthFactor: 1,
              heightFactor: 0.12,
              child: Column(
                children: [
                  Text('${value?.toStringAsFixed(2) ?? '0.00'}V', style: TextStyle(color: Color(0xFF69E6E6), fontWeight: FontWeight.bold, fontSize: 14.0),),
                  SizedBox(height: 4,),
                  Expanded(child: Image.asset('assets/images/sun.png', fit: BoxFit.scaleDown,),),
                ],
              ),
            ),
          )
        ),
      ],
    );
  }

}

class PvMeterPainter extends CustomPainter {

  PvMeterPainter({
    this.value,
    required this.maxValue,
    this.tickMarkColor = Colors.grey,
    this.tickMarkBoldColor = Colors.cyan,
    this.image
  }) {
    tickMarkPaint.color = tickMarkColor;
    tickMarkBoldPaint.color = tickMarkBoldColor;
  }

  final double? value;
  final double maxValue;
  final double startAngle = math.pi * (140 / 180);
  final Color tickMarkColor;
  final Color tickMarkBoldColor;
  final Image? image;

  double calcAngle(v){
    return ((260.0 / 360.0) * 2 * math.pi / maxValue) * v + startAngle;
  }

  final Paint circlePaint = Paint()
    ..color = Color(0xFF808080)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0
    ..strokeCap = StrokeCap.round
    ..isAntiAlias = true;

  Paint tickMarkPaint = Paint()..color = Colors.grey
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3.0
    ..strokeCap = StrokeCap.round
    ..isAntiAlias = true;

  Paint tickMarkBoldPaint = Paint()..color = Colors.cyan
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3.0
    ..strokeCap = StrokeCap.round
    ..isAntiAlias = true;

  final outerCircleColor = Color(0xFF808080);
  final tickMarkPoints = <Offset>[];
  final tickMarkBoldPoints = <Offset>[];
  final innerFilter = MaskFilter.blur(BlurStyle.inner, 5);
  final outerFilter = MaskFilter.blur(BlurStyle.outer, 10);
  final solidFilter = MaskFilter.blur(BlurStyle.solid, 5);
  void drawDial(Canvas canvas, Size size) {
    double frameRadius = math.min(size.width, size.height) / 2;
    double halfWidth = size.width / 2;
    double halfHeight = size.height / 2;

    circlePaint
      ..strokeWidth = 2
      ..color = outerCircleColor
      ..maskFilter = null;
    canvas.drawCircle(Offset(halfWidth, halfHeight), frameRadius, circlePaint);

    circlePaint
      ..strokeWidth = 2
      ..color = tickMarkBoldColor
      ..maskFilter = innerFilter;
    var innerCircleRadius = frameRadius / 2.0 + (frameRadius / 11.5 / 2.0);
    canvas.drawCircle(Offset(halfWidth, halfHeight), innerCircleRadius - circlePaint.strokeWidth, circlePaint);

    circlePaint
      ..strokeWidth = frameRadius / 11.5
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;
    Rect rect1 = Rect.fromCircle(center: Offset(halfWidth, halfHeight), radius: innerCircleRadius);
    circlePaint.maskFilter = outerFilter;
    canvas.drawArc(rect1, calcAngle(0.0), (260.0 / 360.0) * 2 * math.pi, false, circlePaint);

    circlePaint
      ..maskFilter = solidFilter
      ..color = tickMarkBoldColor.withAlpha(96);
    canvas.drawArc(rect1, calcAngle(0.0), (260.0 / 360.0) * 2 * math.pi, false, circlePaint);

    double tickMarkRadius = frameRadius - 4 - tickMarkPaint.strokeWidth;

    tickMarkPoints.clear();
    tickMarkBoldPoints.clear();
    for(var i = 0; i < 45; i = i + 1) {
      var angle = calcAngle(i);
      var x = tickMarkRadius * math.cos(angle) + halfWidth;
      var y = tickMarkRadius * math.sin(angle) + halfHeight;
      if ((i % 5) == 0) {
        tickMarkBoldPoints.add(Offset(x, y));
      } else {
        tickMarkPoints.add(Offset(x, y));
      }
    }
    canvas.drawPoints(dui.PointMode.points, tickMarkPoints, tickMarkPaint);
    canvas.drawPoints(dui.PointMode.points, tickMarkBoldPoints, tickMarkBoldPaint);
  }

  final Paint pointerPaint = Paint()
    ..color = Colors.red
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3.0
    ..strokeCap = StrokeCap.round
    ..isAntiAlias = true;
  final pointerPath = Path();
  void drawPointer(Canvas canvas, Size size) {
    double frameRadius = math.min(size.width, size.height) / 2;
    double halfWidth = size.width / 2;
    double halfHeight = size.height / 2;

    double pointerFarRadius = frameRadius - 4 - tickMarkPaint.strokeWidth - 4;
    double pointerNearRadius = frameRadius / 2.0 + (frameRadius / 11.5 / 2.0);
    var angle = calcAngle(value ?? 0);
    var x = pointerFarRadius * math.cos(angle) + halfWidth;
    var y = pointerFarRadius * math.sin(angle) + halfHeight;
    var nearX = pointerNearRadius * math.cos(angle) + halfWidth;
    var nearY = pointerNearRadius * math.sin(angle) + halfHeight;
    pointerPath.reset();
    pointerPath.moveTo(nearX, nearY);
    pointerPath.lineTo(x, y);
    canvas.drawLine(Offset(nearX, nearY), Offset(x, y), pointerPaint);
    // canvas.drawPath(pointerPath, pointerPaint);
    // canvas.drawShadow(pointerPath, Colors.blue, 4, false);
  }

  final glassPaint = Paint()
    ..color = Color(0x2EFFFFFF)
    ..isAntiAlias = true;
  void drawGlass(Canvas canvas, Size size) {
    double frameRadius = math.min(size.width, size.height) / 2;
    double halfWidth = size.width / 2;
    double halfHeight = size.height / 2;

    final rect = Rect.fromLTRB(0.0, 0.0, size.width, halfHeight * 0.98);
    canvas.clipRect(rect);
    Rect rect1 = Rect.fromCircle(center: Offset(halfWidth, halfHeight), radius: frameRadius);
    canvas.drawArc(rect1, math.pi, math.pi, true, glassPaint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // print("size: $size");
    drawDial(canvas, size);
    drawPointer(canvas, size);
    drawGlass(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

}