import 'package:kgis_mobile/utils/utils.dart';
import 'package:kgis_mobile/view/auth/login.dart';
import 'package:kgis_mobile/view/dashboard/dashboard_admin_page.dart';
import 'package:kgis_mobile/view/dashboard/dashboard_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

import 'conn/API.dart';
import 'firebase_options.dart';

Future<void> main() async {
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  var email = prefs.getString('email');
  var roleId = prefs.getString('role_id');
  var isApprove = prefs.getBool('is_approve');

  ///back
  // AwesomeNotifications().initialize(
  //     null,
  //     [
  //       NotificationChannel(
  //         channelKey: 'key1',
  //         channelName: 'Proto Coders Point',
  //         channelDescription: "Notification example",
  //         defaultColor: Color(0XFF9050DD),
  //         ledColor: Colors.white,
  //         playSound: true,
  //         enableLights:true,
  //         enableVibration: true
  //       )
  //     ]
  // );

  // await Workmanager().initialize(
  //   callbackDispatcher, // The top level function, aka callbackDispatcher
  //   isInDebugMode: false // This should be false
  // );

  // await Workmanager().cancelAll();

  // await Workmanager().registerPeriodicTask(
  //     "2",
  //     "simplePeriodicTask",
  //     frequency: Duration(minutes: 15),
  // );

  runApp(
      // Scaffold(
      //   appBar: AppBar(title: Text('KGIS'),),
      //   body: Container(
      //     width: 100,
      //     height: 100,
      //     child: Text('Test'),
      //   ),
      // )
      Phoenix(
    child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MyApp(email: email, isApprove: isApprove, roleId: roleId)),
  ));
}

// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) async {
//     DateTime now = DateTime.now();
//     String formattedDate = DateFormat('yyyy-MM-dd').format(now);
//     print("prefPresence");
//     print(formattedDate);
//     print("prefPresence");

//     var prefs = SharedPreferences.getInstance();
//     prefs.catchError((onError) {
//       print(onError);
//     });
//     // String prefPresence = prefs.getString('presence');
//     // String prefEmail = prefs.getString('email');

//     // print("prefPresence");
//     // print(prefPresence);
//     // print(prefEmail);
//     // print("prefPresence");

//     AwesomeNotifications().createNotification(
//       content: NotificationContent(
//         id: 1,
//         channelKey: 'key1',
//         title: 'Reminder Absensi',
//         body: 'Anda belum melakukan absen, silahkan lakukan absen pada aplikasi KGIS'
//       )
//     );
//     return Future.value(true);
//   });
// }

class MyApp extends StatelessWidget {
  final email;
  final isApprove;
  final roleId;

  MyApp(
      {Key? key,
      @required this.email,
      @required this.isApprove,
      @required this.roleId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BPJT Teknik',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      themeMode: ThemeMode.light,
      home: CollectionApp(email, isApprove, roleId),
    );
  }
}

class CollectionApp extends StatefulWidget {
  final email;
  final isApprove;
  final roleId;

  CollectionApp(this.email, this.isApprove, this.roleId);

  @override
  _CollectionAppState createState() =>
      _CollectionAppState(email, isApprove, roleId);
}

class _CollectionAppState extends State<CollectionApp> {
  bool _loading = true;

  late String fcmToken;

  var email;
  var isApprove;
  var roleId;
  var _user;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  _CollectionAppState(email, isApprove, roleId) {
    this.email = email;
    this.isApprove = isApprove;
    this.roleId = roleId;
  }

  late String appName;
  late String packageName;
  late String version;
  late String buildNumber;

  _getInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appName = packageInfo.appName;
      packageName = packageInfo.packageName;
      version = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
    });
  }

  _getPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    email ??= prefs.getString('email');

    roleId ??= prefs.getString('role_id');

    isApprove ??= prefs.getBool('is_approve');
  }

  _getUser(userEmail) async {
    await API.getUserByEmail(userEmail, version).then((response) {
      setState(() {
        _user = response;
      });
    });

    return _user;
  }

  @override
  void initState() {
    super.initState();

    ///kode awal
    // _firebaseMessaging.configure(
    //   onMessage: (Map<String, dynamic> message) async {
    //     print("onMessage: $message");
    //   },
    //   onLaunch: (Map<String, dynamic> message) async {
    //     print("onLaunch: $message");
    //   },
    //   onResume: (Map<String, dynamic> message) async {
    //     print("onResume: $message");
    //   },
    // );
    // _firebaseMessaging.getToken().then((String token) {
    //   // assert(token != null);
    //   fcmToken = token;
    // });
    ///tambahan
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("onMessage: $message");
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("onLaunch: $message");
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    _firebaseMessaging.getToken().then((String? token) {
      // assert(token != null);
      fcmToken = token ?? '';
    });

    _getInfo().then((resInfo) {
      _getPref().then((res) async {
        if (await Utils.checkConnection()) {
          _getUser(email).then((resUser) async {
            if (resUser != null) {
              if (resUser["should_logout"]) {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.clear();
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => LoginPage()),
                    (Route<dynamic> route) => false);
              }

              if (resUser["should_update"]) {
                //TODO Show popup and action button exit(0)
              }

              if (resUser["fcm_token"] == null) {
                //Update fcm_token
              }
            }
          });
        }

        setState(() {
          _loading = false;
        });
      });
    });
  }

  ///tambahan
  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print("onResume: $message");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primaryColor: Theme.of(context).primaryColor, fontFamily: 'Lato'),
        themeMode: ThemeMode.light,
        home: _loading
            ? const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              )
            : (email != null && email != 'null')
                ? (roleId.toString() == "1"
                    ? DashboardAdminPage()
                    : DashboardPage())
                : LoginPage()
        // home: LoginPage()
        );
  }
}
