import 'package:kgis_mobile/utils/utils.dart';
import 'package:flutter/material.dart';
// import 'package:package_info/package_info.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'helper/main_helper.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String? appName;
  String? packageName;
  String? version;
  String? buildNumber;

  _getInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appName = packageInfo.appName;
      packageName = packageInfo.packageName;
      version = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
    });
  }

  @override
  void initState() {
    super.initState();
    _getInfo();
  }

  @override
  Widget build(BuildContext context) {
    var timeNow = DateTime.now();

    return Scaffold(
        appBar: AppBar(
          title: const Text('Tentang'),
          backgroundColor: colorPrimary,
        ),
        body: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Bidang Teknik",
                style: TextStyle(fontSize: 20.0),
              ),
              const Text(
                "Badan Pengatur Jalan Tol",
                style: TextStyle(fontSize: 20.0),
              ),
              const Text(
                "Kementerian PUPR",
                style: TextStyle(fontSize: 20.0),
              ),
              Text("${monthIndo(timeNow.month)} ${timeNow.year}"),
              Text(
                  version == null || version == ""
                      ? 'Loading Version...'
                      : "Versi " + version!,
                  style: const TextStyle(
                      color: Colors.black, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center),
              Text(
                  buildNumber == null || buildNumber == ""
                      ? 'Loading ...'
                      : "+" + buildNumber!,
                  style: const TextStyle(
                      color: Colors.black,
                      fontStyle: FontStyle.italic,
                      fontSize: 11.0),
                  textAlign: TextAlign.center),
            ],
          ),
        ));
  }
}
