import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:pvl/generated/l10n.dart';
import '../../model.dart';

class DialogTitle extends StatelessWidget {
  const DialogTitle({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.cyan,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Text(
        title ?? '',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class OneActionBar extends StatelessWidget {
  const OneActionBar({
    Key? key,
    this.text,
    this.onPressed,
  }) : super(key: key);

  final String? text;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    final bText = text ?? S.of(context).OK;
    final bOnPressed =
        onPressed ?? () => Navigator.of(context, rootNavigator: true).pop();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(
          height: 1,
          color: Colors.black38,
        ),
        TextButton(
          onPressed: bOnPressed,
          child: Container(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
            width: double.infinity,
            child: Text(
              bText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 16.0,
                  color: Color(0xFF494949),
                  fontWeight: FontWeight.normal),
            ),
          ),
        ),
      ],
    );
  }
}

class TwoActionsBar extends StatelessWidget {
  const TwoActionsBar({
    Key? key,
    this.leftText,
    this.onLeftPressed,
    this.rightText,
    this.onRightPressed,
  }) : super(key: key);

  final String? leftText;
  final void Function()? onLeftPressed;
  final String? rightText;
  final void Function()? onRightPressed;

  @override
  Widget build(BuildContext context) {
    final lText = leftText ?? S.of(context).CANCEL;
    final lOnPressed = onLeftPressed ??
        () => Navigator.of(context, rootNavigator: true).pop(false);
    final rText = rightText ?? S.of(context).OK;
    final rOnPressed = onRightPressed ??
        () => Navigator.of(context, rootNavigator: true).pop(true);

    return Column(mainAxisSize: MainAxisSize.min, children: [
      const Divider(
        height: 1,
        color: Colors.black38,
      ),
      Row(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  right: BorderSide(width: 0.0, color: Colors.black38),
                ),
              ),
              child: TextButton(
                onPressed: lOnPressed,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                  width: double.infinity,
                  child: Text(
                    lText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 16.0,
                        color: Color(0xFF494949),
                        fontWeight: FontWeight.normal),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: TextButton(
              child: Container(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                width: double.infinity,
                child: Text(
                  rText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 16.0,
                      color: Color(0xFF494949),
                      fontWeight: FontWeight.normal),
                ),
              ),
              onPressed: rOnPressed,
            ),
          ),
        ],
      ),
    ]);
  }
}

Future<void> showAlertDialog(
    BuildContext context, String? title, String? message) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: DialogTitle(title: title),
        titlePadding: EdgeInsets.zero,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Text(message ?? ''),
            ),
            OneActionBar(),
          ],
        ),
      );
    },
  );
}

Future<bool?> showConfirmDialog(
  BuildContext context,
  String? title,
  String? message, {
  String? leftText,
  void Function()? onLeftPressed,
  String? rightText,
  void Function()? onRightPressed,
}) async {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        title: DialogTitle(title: title),
        titlePadding: EdgeInsets.zero,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Text(message ?? ''),
            ),
            TwoActionsBar(
              leftText: leftText,
              onLeftPressed: onLeftPressed,
              rightText: rightText,
              onRightPressed: onRightPressed,
            ),
          ],
        ),
      );
    },
  );
}

Future<void> showProcessingDialog(
    BuildContext context, String? title, String? message,
    {bool cancelable = false}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: DialogTitle(title: title),
            titlePadding: EdgeInsets.zero,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            contentPadding: EdgeInsets.zero,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SpinKitFadingCircle(
                            color: Colors.black12, size: 32.0),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(message ?? ''),
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: cancelable,
                  child: OneActionBar(
                    text: S.of(context).CANCEL,
                  ),
                ),
              ],
            ),
          ));
    },
  );
}

void dismissProcessingDialog(BuildContext? processingContext) {
  if (processingContext != null) {
    Navigator.of(processingContext).pop();
  }
}

Future<void> showProcessingDialogWithLongMessage(
    BuildContext context, String? title, String? message,
    {bool cancelable = false}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: DialogTitle(title: title),
            titlePadding: EdgeInsets.zero,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            contentPadding: EdgeInsets.zero,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SpinKitFadingCircle(
                            color: Colors.black12, size: 32.0),
                        const SizedBox(
                          width: 4,
                        ),
                        Expanded(child: Text(message ?? ''),),
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: cancelable,
                  child: OneActionBar(
                    text: S.of(context).CANCEL,
                  ),
                ),
              ],
            ),
          ));
    },
  );
}

Future<String?> showSaveProfileDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      final TextEditingController textController = TextEditingController();
      return AlertDialog(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DialogTitle(title: S.of(context).Save_Current_Configuration),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              constraints: const BoxConstraints(
                minWidth: 320,
              ),
              child: Row(
                children: [
                  Text('${S.of(context).Name}: '),
                  Expanded(
                    child: CupertinoTextField(
                      controller: textController,
                      maxLength: 255,
                      keyboardType: TextInputType.name,
                      style: const TextStyle(fontSize: 18, height: 1.6),
                    ),
                  ),
                ],
              ),
            ),
            TwoActionsBar(
              onLeftPressed: () =>
                  Navigator.of(context, rootNavigator: true).pop(),
              onRightPressed: () => Navigator.of(context, rootNavigator: true)
                  .pop(textController.text),
            ),
          ],
        ),
      );
    },
  );
}

Future<double?> showSpinDialog({
  required BuildContext context,
  required Param param,
  required double value,
  double scale = 1,
}) {
  return showDialog<double>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      double? _value;
      return AlertDialog(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DialogTitle(title: param.title),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              constraints: const BoxConstraints(
                minWidth: 320,
              ),
              child: SpinBox(
                min: param.min * scale,
                max: param.max * scale,
                step: param.step,
                decimals: param.decimals,
                value: value * scale,
                onChanged: (value) {
                  _value = value;
                  // print(value);
                },
              ),
            ),
            TwoActionsBar(
              onLeftPressed: () =>
                  Navigator.of(context, rootNavigator: true).pop(),
              onRightPressed: () {
                var pv = _value;
                if (scale > 1 && _value != null) {
                  pv = _value! / scale;
                }
                Navigator.of(context, rootNavigator: true).pop(pv);
              },
            ),
          ],
        ),
      );
    },
  );
}
