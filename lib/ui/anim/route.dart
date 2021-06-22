import 'package:flutter/material.dart';

class LeftToRightRouteBuilder extends PageRouteBuilder {
  final Widget widget;

  LeftToRightRouteBuilder(this.widget)
      : super(
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (BuildContext context, Animation<double> animation1,
          Animation<double> animation2) {
        return widget;
      },
      transitionsBuilder: (BuildContext context,
          Animation<double> animation1,
          Animation<double> animation2,
          Widget child) {
        return SlideTransition(
          position: Tween<Offset>(
              begin: Offset(-1.0, 0.0), end: Offset(0.0, 0.0))
              .animate(CurvedAnimation(
              parent: animation1, curve: Curves.fastOutSlowIn)),
          child: child,
        );
      });
}

class RightToLeftBuilder extends PageRouteBuilder {
  final Widget widget;

  RightToLeftBuilder(this.widget)
      : super(
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (BuildContext context, Animation<double> animation1,
          Animation<double> animation2) {
        return widget;
      },
      transitionsBuilder: (BuildContext context,
          Animation<double> animation1,
          Animation<double> animation2,
          Widget child) {
        return SlideTransition(
          position: Tween<Offset>(
              begin: Offset(1.0, 0.0), end: Offset(0.0, 0.0))
              .animate(CurvedAnimation(
              parent: animation1, curve: Curves.fastOutSlowIn)),
          child: child,
        );
      });
}

class ScalePageRouteBuilder extends PageRouteBuilder {
  final Widget widget;
  ScalePageRouteBuilder(this.widget):super(
      transitionDuration:Duration(milliseconds: 200),
      pageBuilder:(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation){
        return widget;
      },
      transitionsBuilder:(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child){
        return ScaleTransition(child:child,
            scale: Tween(begin: 0.0,end: 1.0)
                .animate(CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn))
        );
      }
  );
}