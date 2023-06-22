import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'src/web_view_stack.dart';
import 'src/navigation_controls.dart';
// import 'src/location_client.dart';
// import 'package:background_location/background_location.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:workmanager/workmanager.dart';
// import 'src/notification.dart' as notif;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// import 'package:intl/intl.dart';
import 'package:move_to_background/move_to_background.dart';
import 'src/menu.dart';
import 'package:location/location.dart' as locat;

StreamSubscription<Position>? positionStream;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigoAccent),
        ),
        home: LoginPage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {}

class User {
  final String username;
  final String password;

  User({
    required this.username,
    required this.password,
  });
}

List<User> users = [
  User(username: 'khaiping', password: '1234'),
  User(username: 'thanakorn', password: '1234'),
];

class LoginPage extends StatefulWidget {
  var title = "Login";
  var loginStatus = false;
  var username = "";
  var userid = 0;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    positionStream?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(widget.title),
      //   backgroundColor: Colors.lightBlue,
      // ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Form(
            key: _formKey,
            child: Padding(
              // padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                      child: Text(
                        "Live Location",
                        style: TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0).withOpacity(1),
                            fontSize: 32),
                      )),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: TextFormField(
                      controller: usernameController,
                      decoration: InputDecoration(
                          fillColor: Colors.grey.shade100,
                          filled: true,
                          hintText: "Username",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          )),
                      // const InputDecoration(
                      //     border: OutlineInputBorder(), labelText: "Username"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your username';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                          fillColor: Colors.grey.shade100,
                          filled: true,
                          hintText: "Password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          )),
                      // const InputDecoration(
                      //     border: OutlineInputBorder(), labelText: "Password"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 16.0),
                    child: Center(
                      child: MaterialButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            if (loginValidate(
                                usernameController, passwordController)) {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MapViewPage(
                                        widget.username,
                                        users.indexWhere((element) =>
                                                (element.username ==
                                                    widget.username)) +
                                            1)),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Username or Password is invalid')),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Please fill input')),
                            );
                          }
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40)),
                        color: Colors.indigoAccent[400],
                        height: 50,
                        minWidth: 200,
                        child: const Text('Login',
                            style: TextStyle(
                              color: Colors.white,
                            )),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
    );
  }

  bool loginValidate(
      TextEditingController username, TextEditingController password) {
    var filterUser = users.where((i) => (i.username == username.text)).toList();
    if (filterUser.isNotEmpty) {
      {
        if (filterUser[0].password == password.text) {
          widget.username = username.text;
          return true;
        }
      }
    }
    return false;
  }
}

class MapViewPage extends StatefulWidget {
  var title = "Map View";
  String username;
  var userid;

  MapViewPage(this.username, this.userid);

  @override
  State<MapViewPage> createState() => _MapViewPageState();
}

class _MapViewPageState extends State<MapViewPage> {
  get username => widget.username;
  get userid => widget.userid;

  var loadingPercentage = 0;
  var pUrl = 'https://newerp.clicknext.com/livelocation';
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    background_location_request();
    controller = WebViewController()
      ..loadRequest(
        Uri.parse(pUrl),
      );
  }

  Future<bool> check_permissions() async {
    locat.Location _location = locat.Location();

    bool _serviceEnabled;
    locat.PermissionStatus _permissionGranted;

    _serviceEnabled = await _location.serviceEnabled();
    // _serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return true;
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == locat.PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != locat.PermissionStatus.granted) {
        return true;
      }
    }
    return false;
  }

  void background_location_request() async {
    bool unpermission = true;
    while (unpermission) {
      unpermission = await check_permissions();
    }
    late LocationSettings locationSettings;

    if (defaultTargetPlatform == TargetPlatform.android) {
      print("android access");
      locationSettings = AndroidSettings(
          accuracy: LocationAccuracy.high,
          // distanceFilter: 100,
          forceLocationManager: true,
          intervalDuration: const Duration(seconds: 10),
          //(Optional) Set foreground notification config to keep the app alive
          //when going to the background
          foregroundNotificationConfig: const ForegroundNotificationConfig(
            notificationText: "Fetching Location",
            notificationTitle: "Live Location",
            enableWakeLock: true,
          ));
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.fitness,
        distanceFilter: 100,
        pauseLocationUpdatesAutomatically: true,
        // Only set to true if our app will be started up in the background.
        showBackgroundLocationIndicator: false,
      );
    } else {
      locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );
    }

    print("----------------------------------------------------1");
    DatabaseReference ref = FirebaseDatabase.instance.ref("location");

    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) async {

      await ref.child("user$userid").set({
        "lat": position?.latitude,
        "lng": position?.longitude,
        "timestamp": DateTime.now().millisecondsSinceEpoch
      });
      print(position == null
          ? 'Unknown'
          : '${position.latitude.toString()}, ${position.longitude.toString()}');
    });
    // positionStream.
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        MoveToBackground.moveTaskToBack();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Live Location'),
          actions: [
            NavigationControls(controller: controller),
            Menu(controller: controller),
          ],
          automaticallyImplyLeading: true,
        ),
        body: WebViewStack(controller: controller),
      ),
    );
  }
}
