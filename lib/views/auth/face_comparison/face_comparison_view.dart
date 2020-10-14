import 'dart:io';

import 'package:FaceApp/navigation/navigation_controller.dart';
import 'package:FaceApp/navigation/navigation_tabs.dart';
import 'package:FaceApp/services/auth/authentication_repository.dart';
import 'package:FaceApp/utils/widgets/global_dialogs.dart';
import 'package:flutter/material.dart';

class FaceComparisonView extends StatefulWidget {
  final String path;
  FaceComparisonView({Key key, this.path}) : super(key: key);

  @override
  _FaceComparisonViewState createState() => _FaceComparisonViewState();
}

class _FaceComparisonViewState extends State<FaceComparisonView> {
  bool _processingBytes = false;
  File photo;

  @override
  void initState() {
    renderScreenshot();
    super.initState();
  }

  void renderScreenshot() {
    if (mounted) {
      setState(() {
        photo = File(widget.path);
      });
    }
  }

  void _authenticateFace() async {
    setState(() {
      _processingBytes = true;
    });
    bool success = await AuthenticationRepository.verifyFace(photo,
        subjectId: "71625040", galleryName: "MyGallery");
    if (success) {
      GlobalDialogs.displayGeneralDialog(text: "Exito");
    } else {
      GlobalDialogs.displayGeneralDialog(text: "Fallo");
    }
    setState(() {
      _processingBytes = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Verificación Facial'),
          ),
          backgroundColor: Colors.white,
          body: _buildComparator(),
          floatingActionButton: FloatingActionButton(
            onPressed: _authenticateFace,
            child: const Icon(Icons.file_upload),
          ),
        ),
        onWillPop: () async {
          NavigationController.navigation = NavigationTabs(NavTab.FaceDetection);
          return false;
        });
  }

  Widget _buildComparator() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text("Foto tomada",
              style: TextStyle(color: Colors.blue, fontSize: 30)),
          SizedBox(height: 30),
          _processingBytes
              ? SizedBox(
                  height: 350,
                  width: 350,
                  child: Center(
                    child: Text(
                      "procesando...",
                      style: TextStyle(color: Colors.red, fontSize: 30),
                    ),
                  ),
                )
              : (photo != null
                  ? Column(
                      children: <Widget>[
                        Image.file(
                          photo,
                          height: 300,
                          width: 300,
                        ),
                      ],
                    )
                  : SizedBox(
                      height: 350,
                      width: 350,
                      child: Center(
                        child: Text(
                          "No se pudo obtener la imagen",
                          style: TextStyle(color: Colors.red, fontSize: 30),
                        ),
                      ),
                    )),
        ]);
  }
}
