import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pvl/generated/l10n.dart';
import 'common.dart';
import '../../data/preset.dart';

Future<String?> showAuthDialog(BuildContext context, String title, String id) {
  print('id: $id');
  return showDialog<String>(
      barrierDismissible: false,
      context: context,
      builder: (context) => AuthDialog(title: title, id: id),
  );
}

class AuthDialog extends StatefulWidget {
  const AuthDialog({Key? key, required this.title, required this.id}) : super(key: key);

  final String title;
  final String id;

  @override
  _AuthDialogState createState() => _AuthDialogState();
}

class _AuthDialogState extends State<AuthDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController passwordController = TextEditingController();
  bool rememberPassword = false;

  @override
  void initState() {
    super.initState();
    Preset.isRememberPassword(widget.id).then((value) {
      rememberPassword = value;
      setState((){});
      if (rememberPassword) {
        Preset.getPassword(widget.id).then((value) => passwordController.text = value);
      }
    });
  }

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog (
      clipBehavior: Clip.antiAliasWithSaveLayer,
      contentPadding: EdgeInsets.zero,
      title: DialogTitle(title: widget.title,),
      titlePadding: EdgeInsets.zero,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            width: MediaQuery.of(context).size.width*0.9,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text('${S.of(context).Password}: '),
                      Expanded(
                        child: CupertinoTextField(
                          controller: passwordController,
                          maxLength: 6,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: true,
                          style: const TextStyle(fontSize: 18, height: 1.6),
                        ),
                      ),
                    ],
                  ),
                  Center(
                    child: CheckboxListTile(
                      title: Text(S.of(context).Remember_Password),
                      value: rememberPassword,
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (v) {
                        setState(() {
                          rememberPassword = v ?? false;
                          // print('value: $v');
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          TwoActionsBar(
            leftText: S.of(context).CANCEL,
            onLeftPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            rightText: S.of(context).CONNECT,
            onRightPressed: () {
              if (_formKey.currentState!.validate()) {
                Preset.saveRememberPassword(widget.id, rememberPassword);
                if (rememberPassword) {
                  Preset.savePassword(widget.id, passwordController.value.text);
                } else {
                  Preset.savePassword(widget.id, '');
                }
                Navigator.of(context, rootNavigator: true).pop(passwordController.value.text);
              }
            },
          ),
        ],
      ),
    );
  }
}
