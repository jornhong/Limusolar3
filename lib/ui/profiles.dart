import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pvl/generated/l10n.dart';
import 'app_bar.dart';
import '../model.dart';
import '../data/preset.dart';
import 'dialog/common.dart';
import '../ble.dart';
import '../constants.dart';
import '../data/db.dart';

class ProfilesPage extends StatefulWidget {
  const ProfilesPage({Key? key}) : super(key: key);

  @override
  _ProfilesPageState createState() => _ProfilesPageState();
}

class _ProfilesPageState extends State<ProfilesPage> {
  List<Profile>? _list = [];
  int _selectedIndex = 0;

  Future<void> init() async {
    if (Platform.isIOS) {
      return;
    }
    bool? initDb = await Preset.isInitDataFromDb();
    if (initDb == true) {
      return;
    }

    String? path = await getDbFile();
    if (path == null) {
      return;
    }
    try {
      List<Profile> list = await getProfileListFromDb(path);
      if (list.isNotEmpty) {
        await Preset.saveProfiles([Constants.defaultProfile] + list);
      }
      Preset.setInitDataFromDb(true);
      // removeDbFile();
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    init().then((v) {
      Preset.getProfiles().then((value) => setState(() => _list = value));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(context, S.of(context).Profiles),
      body: Column(children: [
        Expanded(
          child: ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              Color textColor, summaryColor;
              if (_selectedIndex == index) {
                textColor = Colors.white;
                summaryColor = Colors.white;
              } else {
                textColor = Theme.of(context).primaryColor;
                summaryColor = Color(0xFF888888);
              }
              return ListTile(
                leading: Image.asset(
                  'assets/images/file.png',
                  width: 48,
                ),
                title: Text(_list?[index].title ?? '',
                  style: TextStyle(color: textColor,),
                ),
                subtitle: Text(_list?[index].summary ?? '',
                  style: TextStyle(color: summaryColor,),
                ),
                tileColor:
                _selectedIndex == index ? Color(0xFF41a5c9) : null,
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
              );
            },
            itemCount: _list?.length ?? 0,
          ),
        ),
        const Divider(
          height: 1.0,
        ),
        Container(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                flex: 4,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: Text(S.of(context).SaveCurrent, overflow: TextOverflow.ellipsis,),
                  onPressed: _onSavePressed,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.fromLTRB(0, 12.0, 0, 12.0),
                  ),
                ),
              ),
              SizedBox(
                width: 4,
              ),
              Expanded(
                flex: 3,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.delete),
                  label: Text(S.of(context).Delete),
                  onPressed: _onDeletePressed,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.fromLTRB(0, 12.0, 0, 12.0),
                  ),
                ),
              ),
              SizedBox(
                width: 4,
              ),
              Expanded(
                flex: 3,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.file_download),
                  label: Text(S.of(context).Load),
                  onPressed: _onLoadPressed,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.fromLTRB(0, 12.0, 0, 12.0),
                  ),
                ),
              ),
            ],
          ),
        )
      ]),
    );
  }

  void _onSavePressed() async {
    if (_list == null) {
      return;
    }
    var title = await showSaveProfileDialog(context);
    if (title == null) {
      return;
    }
    Profile profile = Profile.widthOptionAndTime(
        Provider.of<BatteryOption>(context, listen: false), DateTime.now());
    profile.title = title;
    _list?.add(profile);
    Preset.saveProfiles(_list!);
    setState(() {});
  }

  void _onDeletePressed() async {
    if (_list == null) {
      return;
    }
    if (_selectedIndex == 0) {
      showAlertDialog(context, S.of(context).Tips, S.of(context).This_profile_cannot_be_deleted);
      return;
    }
    var ret = await showConfirmDialog(context, S.of(context).Tips, S.of(context).Sure_you_want_to_delete);
    if (ret == true) {
      _list?.removeAt(_selectedIndex);
      Preset.saveProfiles(_list!);
      setState(() {
        _selectedIndex--;
      });
    }
  }

  void _onLoadPressed() {
    if (_list == null) {
      return;
    }
    var profile = _list?[_selectedIndex];
    if (profile == null) {
      return;
    }
    if (profile.batteryOption == null) {
      showAlertDialog(context, S.of(context).Failure, S.of(context).profile_is_damaged(profile.title));
      return;
    }
    Ble.instance.batteryOption.copyFrom(profile.batteryOption!);
    Preset.saveVoltageType(profile.batteryOption!.systemType);
    Preset.saveBatteryType(profile.batteryOption!.batteryType);
    Preset.saveCurrentBatteryOptions(profile.batteryOption!);
    if (profile.batteryOption!.batteryType == Constants.BATTERY_TYPE_CUSTOM) {
      Ble.instance.customBatteryOption.copyFrom(profile.batteryOption!);
      Preset.saveCustomBatteryOptions(profile.batteryOption!);
    } else {
      Preset.saveCustomBatteryOptions(Constants.batteryTypeCustom);
    }
    // Ble.instance.batteryOption.notify();
    showAlertDialog(context, S.of(context).Success, S.of(context).profile_is_loaded(profile.title));
  }
}

class EntryItem extends StatelessWidget {
  const EntryItem(this.entry);

  final Profile entry;

  Widget _buildTiles(Profile root) {
    return ListTile(
      leading: Image.asset('assets/images/file.png'),
      title: Text(root.title),
      subtitle: Text(root.summary),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTiles(entry);
  }
}
