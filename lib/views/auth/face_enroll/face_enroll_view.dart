import 'package:flutter/material.dart';

class FaceEnrollView extends StatefulWidget {
  FaceEnrollView({Key key}) : super(key: key);

  @override
  _FaceEnrollViewState createState() => _FaceEnrollViewState();
}

class _FaceEnrollViewState extends State<FaceEnrollView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro Facial'),
      ),
      backgroundColor: Colors.white,
      body: Container(),
    );
  }
}