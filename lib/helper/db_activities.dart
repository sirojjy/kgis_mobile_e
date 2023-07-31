import 'package:kgis_mobile/helper/db_activity_details.dart';
import 'package:kgis_mobile/conn/API.dart';
import 'package:kgis_mobile/helper/db.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

class DbActivities {
  static DbActivities? _dbActivities;
  static Database? _database;
  
  DbActivityDetails dbActivityDetail = DbActivityDetails();

  static const columnIsSync = 'is_sync';

  DbActivities._createObject();

  Future<Map<String, dynamic>> getInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    Map<String, dynamic> ret = <String, dynamic>{};

    ret['app_name'] = packageInfo.appName;
    ret['package_name'] = packageInfo.packageName;
    ret['version'] = packageInfo.version;
    ret['build_number'] = packageInfo.buildNumber;

    return ret;
  }

  factory DbActivities() {
    _dbActivities ??= DbActivities._createObject();
    return _dbActivities!;
  }

  Future<Database> get database async {
    var db = new Db();
    _database ??= await db.init();
    return _database!;
  }

  Future<List<Map<String, dynamic>>> select() async {
    Database db = await database;
    var mapList = await db.query('activities', orderBy: 'id');
    return mapList;
  }

  Future<List<Map<String, dynamic>>> selectUnsync() async {
    Database db = await database;
    var mapList = await db.query('activities', where: 'is_sync=?', whereArgs: [0]);
    return mapList;
  }

  Future<int> insert(Map<String, dynamic> params) async {
    Database db = await database;
    int count = await db.insert('activities', params);
    return count;
  }
  
  Future<int> update(Map<String, dynamic> object, int id) async {
    Database db = await database;
    int count = await db.update('activities', object, 
                                where: 'id=?',
                                whereArgs: [id]);
    return count;
  }

  Future<int> delete(int id) async {
    Database db = await database;
    int count = await db.delete('activities', 
                                where: 'id=?', 
                                whereArgs: [id]);
    return count;
  }

  Future<bool> sendActivitiesUnsync() async {
    Map<String, dynamic> version = await getInfo();
    var activitiesMapList = await selectUnsync();
    int count = activitiesMapList.length;
    for (int i=0; i<count; i++) {
      List<String> files = [];

      var activityDetailsMapList = await dbActivityDetail.selectWhereActivityId(activitiesMapList[i]["id"].toString());
      
      for (int n=0; n<activityDetailsMapList.length; n++) {
        files.add(activityDetailsMapList[n]["files"]);
      }

      Map<String, dynamic> params = <String, dynamic>{};
      params["user_id"] = activitiesMapList[i]["user_id"];
      params["activity"] = activitiesMapList[i]["activity"];
      params["long"] = activitiesMapList[i]["long"];
      params["lat"] = activitiesMapList[i]["lat"];
      params["segment"] = activitiesMapList[i]["segment"];
      params["priority"] = activitiesMapList[i]["priority"];
      params["location"] = activitiesMapList[i]["location"];

      await API.storeActivity(
        params,
        files,
        version["version"]
      ).then((response) {
        print("Sync to server");
        print(response);
        if (response["status"] == "success") {
          Map<String, dynamic> row = {
            DbActivities.columnIsSync: 1
          };
          update(row, activitiesMapList[i]["id"]);
        }
      });
    }
    return true;
  }
}