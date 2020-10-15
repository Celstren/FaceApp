import 'package:FaceApp/utils/exports/app_design.dart';
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
      backgroundColor: AppColors.DarkLiver,
      body: Center(
        child: Text("Verificación exitosa",
            style: AppTextStyle.whiteStyle(fontSize: AppFontSizes.title24)),
      ),
    );
  }
}
