import 'dart:io';

import 'package:FaceApp/navigation/navigation_controller.dart';
import 'package:FaceApp/navigation/navigation_tabs.dart';
import 'package:FaceApp/services/auth/authentication_repository.dart';
import 'package:FaceApp/utils/exports/app_design.dart';
import 'package:FaceApp/utils/widgets/custom_dialog.dart';
import 'package:FaceApp/utils/widgets/global_dialogs.dart';
import 'package:FaceApp/utils/widgets/two_options_dialog.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as imglib;

class FaceEnrollView extends StatefulWidget {
  FaceEnrollView({Key key}) : super(key: key);

  @override
  _FaceEnrollViewState createState() => _FaceEnrollViewState();
}

class _FaceEnrollViewState extends State<FaceEnrollView> {
  TextEditingController controller = TextEditingController();
  final picker = ImagePicker();
  File _image;

  void selectImage() {
    showCustomDialog(
        context: context,
        builder: (context) {
          return CustomDialog(
            child: TwoOptionsDialog(
              title: "Cargar imagen",
              leftOptionText: "Cámara",
              onLeftPress: () {
                Navigator.pop(context);
                getImage(ImageSource.camera);
              },
              rightOptionText: "Galería",
              onRightPress: () {
                Navigator.pop(context);
                getImage(ImageSource.gallery);
              },
            ),
          );
        });
  }

  Future getImage(ImageSource source) async {
    final pickedFile = await picker.getImage(source: source);

    if (pickedFile != null) {
      List<int> bytes = await pickedFile.readAsBytes();

      imglib.Image originalImage = imglib.decodeImage(bytes);
      imglib.Image resizedImage =
          imglib.copyResize(originalImage, width: 180, height: 180);
      File _processedFile = await File(pickedFile.path)
          .writeAsBytes(imglib.encodePng(resizedImage));
      if (_processedFile != null) {
        setState(() {
          _image = _processedFile;
        });
      }
    } else {
      print('No image selected.');
    }
  }

  void enrollUser() async {
    bool success = await AuthenticationRepository.enrollFace(_image, subjectId: controller.value.text.trim(), galleryName: "MyGallery");
    if (success) {
      NavigationController.navigation = NavigationTabs(NavTab.LoginDni);
    } else {
      GlobalDialogs.displayGeneralDialog(text: "Fallo registro de usuario");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.DarkLiver,
        body: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 50),
          Text("Registro",
              style: AppTextStyle.whiteStyle(fontSize: AppFontSizes.title36)),
          SizedBox(height: 20),
          _image != null ? _buildImage() : _buildPlaceholder(),
          SizedBox(height: 40),
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
                  enrollUser();
                }
              },
              child: Center(
                child: Text(
                  "Continuar",
                  style:
                      AppTextStyle.whiteStyle(fontSize: AppFontSizes.subitle16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return GestureDetector(
      onTap: selectImage,
      child: Container(
        height: 180,
        width: 180,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: FileImage(_image),
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return GestureDetector(
      onTap: selectImage,
      child: Container(
        height: 180,
        width: 180,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.ShadowBlue,
        ),
        child: Center(
          child: Icon(
            Icons.person,
            color: AppColors.PrimaryWhite,
            size: 100,
          ),
        ),
      ),
    );
  }

  Widget _buildProcessingImage() {
    return GestureDetector(
      onTap: selectImage,
      child: Container(
        height: 180,
        width: 180,
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.ShadowBlue,
        ),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
