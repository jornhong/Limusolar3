import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info/package_info.dart';
import 'package:pvl/generated/l10n.dart';
import 'app_bar.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String _version = 'v3.0.0';
  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      // String appName = packageInfo.appName;
      // String packageName = packageInfo.packageName;
      String version = packageInfo.version;
      String buildNumber = packageInfo.buildNumber;
      setState(() {
        _version = "v$version (build:$buildNumber)";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MyAppBar(context, S.of(context).About),
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(4, 32, 4, 42),
            ),
            Image.asset('assets/images/pvlogic128x128.png',),
            const SizedBox(height: 8,),
            const Text('PVMobileSuite', style: TextStyle(color: Color(0xFF333333), fontSize: 24.0, fontWeight: FontWeight.bold),),
            const SizedBox(height: 4,),
            Text(_version),
            const SizedBox(height: 32,),
            Text(S.of(context).Solar_Controller_Manager_For_Mobile_Phone),
            TextButton(
              onPressed: () async {
                String url = 'http://www.limutech.com/static/privacy.html';
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  throw 'Could not launch $url';
                }
              },
              child: Text(S.of(context).Privacy,
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: Colors.blue,
                ),
              ),
            ),
            Expanded(child: Container(),),
            Linkify(
              onOpen: (link) async {
                String url = 'http://www.solartechnology.co.uk/pv-logic';
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  throw 'Could not launch $link';
                }
              },
              text: "http://www.solartechnology.co.uk/pv-logic",
            ),
            const SizedBox(height: 64,),
          ],
        ),
    );
  }
}
