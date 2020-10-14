import 'package:FaceApp/navigation/navigation_controller.dart';
import 'package:FaceApp/navigation/navigation_tabs.dart';
import 'package:FaceApp/views/auth/face_comparison/face_comparison_view.dart';
import 'package:FaceApp/views/auth/face_detection/face_detection_view.dart';
import 'package:flutter/material.dart';

class FaceApp extends StatefulWidget {
  FaceApp({Key key}) : super(key: key);

  @override
  _FaceAppState createState() => _FaceAppState();
}

class _FaceAppState extends State<FaceApp> {

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
            case NavTab.Login:
              return Scaffold();
              break;
            case NavTab.FaceDetection:
              return FaceDetectionView();
              break;
            case NavTab.FaceComparison:
              return FaceComparisonView(bytes: snapshot.data.params is List<int> ? snapshot.data.params : []);
              break;
          }
          return Scaffold();
        },
      ),
    );
  }
}
