import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:select_dialog/select_dialog.dart';
import 'package:pvl/generated/l10n.dart';
import '../../current_locale.dart';
import '../../data/preset.dart';

// void _showLanguageDialog(BuildContext context) {
//   String ex1 = 'English';
//
//   SelectDialog.showModal<String>(
//     context,
//     label: 'Language(语言)',
//     showSearchBox: false,
//     constraints: BoxConstraints(maxHeight: 180.0),
//     selectedValue: ex1,
//     items: ['English', 'French', 'German'],
//     onChange: (String selected) {
//       setState(() {
//         ex1 = selected;
//       });
//     },
//   );
// }

void setLocale(BuildContext context, String? languageCode) {
  switch(languageCode) {
    case 'en':
      Provider.of<CurrentLocale>(context, listen: false)
          .setLocale(const Locale('en'));
      break;
    case 'fr':
      Provider.of<CurrentLocale>(context, listen: false)
          .setLocale(const Locale('fr'));
      break;
    case 'de':
      Provider.of<CurrentLocale>(context, listen: false)
          .setLocale(const Locale('de'));
      break;
    default:
      Provider.of<CurrentLocale>(context, listen: false)
          .setLocale(Locale(Intl.systemLocale));
      break;
  }
}

void showLanguageDialog(BuildContext context) async {
  String? languageCode = await Preset.getLanguageCode();
  String selectedValue = languageCode ?? '';
  String? ret = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(S.of(context).Language),
          content: StatefulBuilder(builder: (context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconRadioListTile(
                    icon: '',
                    text: S.of(context).Follow_system,
                    value: '',
                    groupValue: selectedValue,
                    onChanged: (String? value) {
                      setState(() {
                        selectedValue = value ?? '';
                      });
                      Navigator.of(context, rootNavigator: true).pop(value);
                    }
                ),
                IconRadioListTile(
                    icon: 'assets/images/en.png',
                    text: S.of(context).English,
                    value: 'en',
                    groupValue: selectedValue,
                    onChanged: (String? value) {
                      setState(() {
                        selectedValue = value ?? '';
                      });
                      Navigator.of(context, rootNavigator: true).pop(value);
                    }
                ),
                IconRadioListTile(
                    icon: 'assets/images/fr.png',
                    text: S.of(context).French,
                    value: 'fr',
                    groupValue: selectedValue,
                    onChanged: (String? value) {
                      Navigator.of(context, rootNavigator: true).pop(value);
                    }
                ),
                IconRadioListTile(
                    icon: 'assets/images/de.png',
                    text: S.of(context).German,
                    value: 'de',
                    groupValue: selectedValue,
                    onChanged: (String? value) {
                      Navigator.of(context, rootNavigator: true).pop(value);
                    }
                ),
              ],
            );
          }),
        );
      }
  );

  print('ret: $ret');
  if (ret == null) {
    return;
  }

  Preset.setLanguageCode(ret);
  setLocale(context, ret);
}

class IconRadioListTile<T> extends StatelessWidget {
  const IconRadioListTile({
    Key? key,
    required this.icon,
    required this.text,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  }) : super(key: key);

  final String icon;
  final String text;
  final T value;
  final T groupValue;
  final ValueChanged<T?>? onChanged;
  @override
  Widget build(BuildContext context) {
    return RadioListTile(
      title: Row(
        children: [
          _getIcon(),
          const SizedBox(width: 4,),
          Text(text),
        ],
      ),
      value: value,
      groupValue: groupValue,
      controlAffinity: ListTileControlAffinity.trailing,
      onChanged: onChanged,
    );
  }

  Widget _getIcon() {
    if (icon.isEmpty) {
      return Icon(Icons.language, size: 32, color: Colors.cyan,);
    } else {
      return Image.asset(icon, width: 42,);
    }
  }
}