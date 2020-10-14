import 'package:flutter/material.dart';

class LoginDniView extends StatefulWidget {
  LoginDniView({Key key}) : super(key: key);

  @override
  _LoginDniViewState createState() => _LoginDniViewState();
}

class _LoginDniViewState extends State<LoginDniView> {

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(
            title: const Text('Verificación Facial'),
          ),
          backgroundColor: Colors.white,
          body: _buildContent(),
        );
  }

  Widget _buildContent() {
    return Container();
  }
}