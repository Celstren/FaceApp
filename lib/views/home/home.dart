import 'package:flutter/material.dart';

class HomeView extends StatefulWidget {
  HomeView({Key key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(
            title: const Text('Inicio'),
          ),
          backgroundColor: Colors.white,
          body: Center(
            child: Text("Verificación exitosa"),
          ),
        );
  }
}