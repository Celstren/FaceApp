import 'dart:io';

import 'package:FaceApp/services/auth/authentication_repository.dart';
import 'package:FaceApp/utils/widgets/global_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

class FaceComparisonView extends StatefulWidget {
  final List<int> bytes;
  FaceComparisonView({Key key, this.bytes}) : super(key: key);

  @override
  _FaceComparisonViewState createState() => _FaceComparisonViewState();
}

class _FaceComparisonViewState extends State<FaceComparisonView> {
  File photoFile;
  bool _processingBytes = true;

  @override
  void initState() {
    initializePhoto();
    super.initState();
  }

  void initializePhoto() async {
    try {
      if (widget.bytes != null) {
        _processingBytes = true;
        final path = join((await getTemporaryDirectory()).path, '${DateTime.now().millisecondsSinceEpoch}.png');
        File _file = await File(path).writeAsBytes(widget.bytes);
        photoFile = await FlutterExifRotation.rotateAndSaveImage(path: _file.path);
      }
    } catch (e) {
      print(e);
    }
    setState(() {
      _processingBytes = false;
    });
  }

  void _authenticateFace() async {
    bool success = await AuthenticationRepository.verifyFace(photoFile, subjectId: "71625040", galleryName: "MyGallery");
    if (success) {
      GlobalDialogs.displayGeneralDialog(text: "Exito");
    } else {
      GlobalDialogs.displayGeneralDialog(text: "Fallo");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Comparison View'),
      ),
      backgroundColor: Colors.white,
      body: _buildComparator(),
      floatingActionButton: FloatingActionButton(
        onPressed: _authenticateFace,
        child: const Icon(Icons.file_upload),
      ),
    );
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
              : (photoFile != null
                  ? Image(
                      height: 350,
                      width: 350,
                      image: FileImage(photoFile),
                      fit: BoxFit.cover,
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
