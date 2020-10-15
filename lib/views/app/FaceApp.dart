import 'package:FaceApp/navigation/navigation_controller.dart';
import 'package:FaceApp/navigation/navigation_tabs.dart';
import 'package:FaceApp/utils/widgets/global_dialogs.dart';
import 'package:FaceApp/views/auth/face_comparison/face_comparison_view.dart';
import 'package:FaceApp/views/auth/face_detection/face_detection_view.dart';
import 'package:FaceApp/views/auth/face_enroll/face_enroll_view.dart';
import 'package:FaceApp/views/auth/login_by_dni/login_dni_view.dart';
import 'package:FaceApp/views/home/home.dart';
import 'package:flutter/material.dart';

class FaceApp extends StatefulWidget {
  FaceApp({Key key}) : super(key: key);

  @override
  _FaceAppState createState() => _FaceAppState();
}

class _FaceAppState extends State<FaceApp> {

  @override
  void initState() {
    GlobalDialogs.initContext(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "FaceApp",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: StreamBuilder<NavigationTabs>(
        stream: NavigationController.navigationStream,
        builder: (BuildContext context, AsyncSnapshot<NavigationTabs> snapshot) {
          switch (snapshot?.data?.tab) {
            case NavTab.LoginDni:
              return LoginDniView();
              break;
            case NavTab.FaceDetection:
              return FaceDetectionView();
              break;
            case NavTab.FaceComparison:
              return FaceComparisonView(path: snapshot.data.params is String ? snapshot.data.params : null);
              break;
            case NavTab.FaceEnroll:
              return FaceEnrollView();
              break;
            case NavTab.Home:
              return HomeView();
              break;
          }
          return Scaffold();
        },
      ),
    );
  }
}
