import 'package:kgis_mobile/conn/API.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'db.dart';

class DbSegments {
  static DbSegments? _dbSegments;
  static Database? _database;

  DbSegments._createObject();

  Future<Map<String, dynamic>> getInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    Map<String, dynamic> ret = <String, dynamic>{};

    ret['app_name'] = packageInfo.appName;
    ret['package_name'] = packageInfo.packageName;
    ret['version'] = packageInfo.version;
    ret['build_number'] = packageInfo.buildNumber;

    return ret;
  }
  
  factory DbSegments() {
    _dbSegments ??= DbSegments._createObject();
    return _dbSegments!;
  }

  Future<Database> get database async {
    var db = new Db();
    _database ??= await db.init();
    return _database!;
  }

  Future<List<Map<String, dynamic>>> select() async {
    Database db = await database;
    var mapList = await db.query('segments', orderBy: 'id');

    if (mapList.isEmpty) {
      Map<String, dynamic> version = await getInfo();

      await API.getSegment("", "", "", "true", version["version"]).then((response) {
        Batch batch = db.batch();
        for (int i = 0; i < response.length; i++) {
          batch.insert('segments', {'segment': response[i]});
        }
        batch.commit(noResult: true);
      });

      mapList = await db.query('segments', orderBy: 'id');
    }
    
    return mapList;
  }
}