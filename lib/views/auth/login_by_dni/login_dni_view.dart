import 'package:FaceApp/navigation/navigation_controller.dart';
import 'package:FaceApp/navigation/navigation_tabs.dart';
import 'package:FaceApp/utils/exports/app_design.dart';
import 'package:flutter/material.dart';

class LoginDniView extends StatefulWidget {
  LoginDniView({Key key}) : super(key: key);

  @override
  _LoginDniViewState createState() => _LoginDniViewState();
}

class _LoginDniViewState extends State<LoginDniView> {
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.DarkLiver,
        body: SingleChildScrollView(
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 250,
            width: 250,
            child: Center(
              child: Text("FaceApp",
                  style: AppTextStyle.whiteStyle(
                    fontSize: AppFontSizes.title36,
                  )),
            ),
          ),
          SizedBox(height: 20),
          Container(
            height: 50,
            width: 300,
            padding: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: AppBorderRadius.all(radius: AppRadius.radius15),
              color: AppColors.PrimaryWhite,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.PrimaryBlack.withAlpha(50),
                  offset: Offset(2.0, 2.0),
                ),
              ],
            ),
            child: Center(
              child: TextField(
                controller: controller,
                style: AppTextStyle.blackStyle(
                  fontSize: AppFontSizes.text14,
                ),
                decoration: InputDecoration.collapsed(
                  hintText: "Ingrese dni...",
                  hintStyle: AppTextStyle.darkGreyStyle(
                    fontSize: AppFontSizes.text14,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 40),
          Container(
            height: 40,
            width: 200,
            decoration: BoxDecoration(
              borderRadius: AppBorderRadius.all(radius: AppRadius.radius15),
              color: AppColors.ShadowBlue,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.PrimaryBlack.withAlpha(50),
                  offset: Offset(2.0, 2.0),
                ),
              ],
            ),
            child: FlatButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                String dni = controller.value.text.trim();
                if (dni != null && dni.isNotEmpty) {
                  NavigationController.navigation =
                      NavigationTabs(NavTab.FaceDetection, params: dni);
                }
              },
              child: Center(
                child: Text(
                  "Ingresar",
                  style:
                      AppTextStyle.whiteStyle(fontSize: AppFontSizes.subitle16),
                ),
              ),
            ),
          ),
          SizedBox(height: 60),
          Text("No estás registrado aún?", style: AppTextStyle.whiteStyle(fontSize: AppFontSizes.subitle16)),
          SizedBox(height: 10),
          Container(
            height: 40,
            width: 200,
            child: FlatButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                NavigationController.navigation =
                    NavigationTabs(NavTab.FaceEnroll);
              },
              child: Center(
                child: Text(
                  "Registrate aquí",
                  style:
                      AppTextStyle.blueStyle(fontSize: AppFontSizes.subitle16, decoration: TextDecoration.underline),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
