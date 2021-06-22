import 'package:flutter/material.dart';
import 'package:string_validator/string_validator.dart';
import 'package:pvl/generated/l10n.dart';
import 'common.dart';
import '../../ble.dart';

void showSettingsDialog(BuildContext context) async {
  String? ret = await showDialog<String>(
      context: context,
      builder: (context) {
        String selectedValue = '';
        return AlertDialog(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          contentPadding: EdgeInsets.zero,
          title: DialogTitle(title: S.of(context).Edit_Name_or_Password),
          titlePadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile(
                  title: Text(S.of(context).Change_Device_Name),
                  subtitle: Text(S.of(context).Change_Device_Name_summary),
                  value: 'name',
                  groupValue: selectedValue,
                  controlAffinity: ListTileControlAffinity.trailing,
                  contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                  onChanged: (String? value) {
                    Navigator.of(context, rootNavigator: true).pop(value);
                  }
              ),
              const Divider(height: 1, color: Colors.cyan,),
              RadioListTile(
                  title: Text(S.of(context).Change_Access_Password),
                  subtitle: Text(S.of(context).Change_Access_Password_summary),
                  value: 'password',
                  groupValue: selectedValue,
                  controlAffinity: ListTileControlAffinity.trailing,
                  contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                  onChanged: (String? value) {
                    Navigator.of(context, rootNavigator: true).pop(value);
                  }
              ),
              OneActionBar(
                text: S.of(context).CANCEL,
              )
            ],
          ),
        );
      }
  );

  switch(ret) {
    case 'name':
      var name = await showEditNameDialog(context, Ble.instance.currentDevice?.name ?? '');
      if (name != null) {
        if (name.length == 6 && isAlphanumeric(name)) {
          Ble.instance.writeDeviceName(name);
        }
      }
      break;
    case 'password':
      var password = await showEditPasswordDialog(context, Ble.instance.currentDevice?.name ?? '');
      if (password != null) {
        if (password.length >= 4 && password.length <=6 && isAlphanumeric(password)) {
          Ble.instance.writePassword(password);
        }
      }
      break;
  }
}

Future<String?> showEditNameDialog(BuildContext context, String name) {
  return showDialog<String>(
    context: context,
    builder: (context) => EditNameDialog(name: name),
  );
}

class EditNameDialog extends StatefulWidget {
  const EditNameDialog({Key? key, required this.name}) : super(key: key);
  final String name;

  @override
  _EditNameDialogState createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<EditNameDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _textController = TextEditingController();
  String _prefix = '';
  @override
  void initState() {
    super.initState();
    if (widget.name.length > 3) {
      _prefix = widget.name.substring(0, 3);
      _textController.text = widget.name.substring(3);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog (
      clipBehavior: Clip.antiAliasWithSaveLayer,
      contentPadding: EdgeInsets.zero,
      title: DialogTitle(title: S.of(context).Change_Device_Name,),
      titlePadding: EdgeInsets.zero,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(S.of(context).Name_must_be_6_digits_or_characters),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  child: Text(_prefix),
                ),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: Container(
                      child: TextFormField(
                        controller: _textController,
                        keyboardType: TextInputType.name,
                        maxLength: 6,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
                        ),
                        validator: (String? value) {
                          if (value == null) {
                            return S.of(context).Name_cant_be_empty;
                          }
                          if (value.length < 6) {
                            return S.of(context).Name_must_be_6_digits_or_characters;
                          }
                          if (!isAlphanumeric(value)) {
                            return S.of(context).Name_must_be_6_letters_and_numbers;
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
              ]
            ),
          ),
          TwoActionsBar(
            onLeftPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            onRightPressed: () {
              if (_formKey.currentState != null) {
                if (_formKey.currentState!.validate()) {
                  Navigator.of(context).pop(_textController.value.text);
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

Future<String?> showEditPasswordDialog(BuildContext context, String name) {
  return showDialog<String>(
    context: context,
    builder: (context) => EditPasswordDialog(name: name),
  );
}

class EditPasswordDialog extends StatefulWidget {
  const EditPasswordDialog({Key? key, required this.name}) : super(key: key);
  final String name;

  @override
  _EditPasswordDialogState createState() => _EditPasswordDialogState();
}

class _EditPasswordDialogState extends State<EditPasswordDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog (
      clipBehavior: Clip.antiAliasWithSaveLayer,
      contentPadding: EdgeInsets.zero,
      title: DialogTitle(title: S.of(context).Change_Password,),
      titlePadding: EdgeInsets.zero,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(S.of(context).Password_must_be_4_6_digits_or_characters),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    keyboardType: TextInputType.name,
                    enabled: false,
                    initialValue: widget.name,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
                      labelText: S.of(context).Device_Name,
                    ),
                  ),
                  TextFormField(
                    controller: _passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                    maxLength: 6,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
                      labelText: S.of(context).Password,
                    ),
                    validator: (String? value) => _validator(value),
                  ),
                  TextFormField(
                    controller: _confirmPasswordController,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                    maxLength: 6,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
                      labelText: S.of(context).Confirm_Password,
                    ),
                    validator: (String? value) => _validator(value),
                  ),
                ],
              ),
            ),
          ),
          TwoActionsBar(
            onLeftPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            onRightPressed: () {
              if (_formKey.currentState != null) {
                if (_formKey.currentState!.validate()) {
                  Navigator.of(context).pop(_passwordController.value.text);
                }
              }
            },
          ),
        ],
      ),
    );
  }

  String? _validator(String? value) {
    if (value == null) {
      return S.of(context).Password_cant_be_empty;
    }
    if (value.length < 4) {
      return S.of(context).Password_must_be_4_6_digits_or_characters;
    }
    if (!isAlphanumeric(value)) {
      return S.of(context).Password_must_be_6_letters_and_numbers;
    }
    if (_confirmPasswordController.value.text != _passwordController.value.text) {
      return S.of(context).Password_and_confirm_password_must_be_the_same;
    }
    return null;
  }
}
