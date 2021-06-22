import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:lifecycle/lifecycle.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:pvl/generated/l10n.dart';
import 'current_locale.dart';
import 'ui/anim/route.dart';
import 'ui/main.dart';
import 'ui/about.dart';
import 'ui/ble_dialog.dart';
import 'ui/dashboard.dart';
import 'data/preset.dart';
import 'ble.dart';
import 'ui/dialog/language.dart';
import 'ui/dialog/common.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Preset.init();
  await Ble.instance.init();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CurrentLocale()),
        ChangeNotifierProvider(create: (context) => Ble.instance.bleSession),
        ChangeNotifierProvider(create: (context) => Ble.instance.deviceStatus),
        ChangeNotifierProvider(create: (context) => Ble.instance.systemInfo),
        ChangeNotifierProvider(create: (context) => Ble.instance.eventLog),
        ChangeNotifierProvider(create: (context) => Ble.instance.batteryOption),
      ],
      child: MyApp(),
    ));
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentLocale>(
      builder: (context, currentLocale, child) {
        return MaterialApp(
          title: "PVMobileSuite",
          navigatorObservers: [defaultLifecycleObserver],
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            S.delegate
          ],
          locale: currentLocale.value,
          supportedLocales: [
            const Locale('en'),
            const Locale('fr'),
            const Locale('de'),
          ],
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.cyan,
            primaryColor: Color(0xFF5CC0E4),
            primaryTextTheme: TextTheme(headline6: TextStyle(color: Colors.white)),
          ),
          // home: MyHomePage(title: 'Home Page'),
          initialRoute: '/',
          routes: {
            '/': (BuildContext context) => MyHomePage(),
            '/dashboard': (BuildContext context) => DashboardPage(),
          },
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>{

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      setLocale(context, await Preset.getLanguageCode());
    });
  }

  Future<bool> _onWillPop() async {
    BluetoothDevice? device = await Ble.instance.connectedDevice;
    if (device == null) {
      return true;
    }
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: DialogTitle(title: device.name),
        titlePadding: EdgeInsets.zero,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Text(S.of(context).Do_you_want_to_exit),
            ),
            TwoActionsBar(
              onRightPressed: () async {
                await Ble.instance.disconnect();
                Navigator.of(context, rootNavigator: true).pop(true);
              },
            ),
          ],
        ),
      ),
    )) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPop,
        child:Scaffold(
          appBar: AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
              title: Text(S.of(context).App_Name),
              iconTheme: const IconThemeData(
                color: Colors.white,
              ),
              leading: PopupMenuButton<String>(
                icon: const Icon(Icons.menu),
                itemBuilder: (BuildContext context) =>
                <PopupMenuItem<String>>[
                  PopupMenuItem<String>(
                    value: 'options',
                    child: Text(S.of(context).Options),
                  ),
                  PopupMenuItem<String>(
                    value: 'about',
                    child: Text(S.of(context).About),
                  ),
                  // const PopupMenuItem<String>(
                  //   value: 'quit',
                  //   child: const Text('Quit'),
                  // ),
                ],
                onSelected: (String action) {
                  switch (action) {
                    case 'options':
                      showLanguageDialog(context);
                      break;
                    case 'about':
                      Navigator.push(context, RightToLeftBuilder(AboutPage()));
                      break;
                    case 'quit':
                      SystemNavigator.pop();
                      break;
                  }
                },
              ),
              centerTitle: true,
              actions: <Widget>[
                IconButton(
                    icon: StreamBuilder<DeviceState>(
                      initialData: Ble.instance.currentDeviceState,
                      stream: Ble.instance.deviceState,
                      builder: (c, snapshot) {
                        if (snapshot.data == DeviceState.authorized) {
                          return Icon(Icons.bluetooth_connected);
                        } else {
                          return Icon(Icons.bluetooth_disabled);
                        }
                      },
                    ),
                    onPressed: () {
                      blueIconClick(context);
                    }
                ),
              ]
          ),
          body: MainPage(),
        ),);
  }

}
