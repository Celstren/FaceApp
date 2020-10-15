import 'dart:io';

import 'package:FaceApp/navigation/navigation_controller.dart';
import 'package:FaceApp/navigation/navigation_tabs.dart';
import 'package:FaceApp/services/auth/authentication_repository.dart';
import 'package:FaceApp/utils/exports/app_design.dart';
import 'package:FaceApp/utils/general/constant_helper.dart';
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
  bool processingPhoto = false;

  void selectImage() {
    setState(() {
      processingPhoto = true;
    });
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
          processingPhoto = false;
          _image = _processedFile;
        });
      }
    } else {
      print('No image selected.');
    }
  }

  void enrollUser() async {
    String dni = controller.value.text.trim();
    if (dni != null && dni.isNotEmpty) {
      if (_image != null) {
        bool success = await AuthenticationRepository.enrollFace(_image,
            subjectId: controller.value.text.trim(),
            galleryName: ConstantHelper.FacialGallery);
            if (success) {
              NavigationController.navigation =
                      NavigationTabs(NavTab.FaceDetection, params: dni);
            } 
      } else {
        GlobalDialogs.displayGeneralDialog(
            text: "Se requiere una foto para el registro");
      }
    } else {
      GlobalDialogs.displayGeneralDialog(
          text: "Se requiere su dni para el registro");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: SafeArea(
          child: Scaffold(
            backgroundColor: AppColors.DarkLiver,
            body: SingleChildScrollView(
              child: _buildContent(),
            ),
          ),
        ),
        onWillPop: () async {
          NavigationController.navigation = NavigationTabs(NavTab.LoginDni);
          return false;
        });
  }

  Widget _buildContent() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * .01,
              left: MediaQuery.of(context).size.width * .05,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 60,
                  width: 60,
                  child: FlatButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      NavigationController.navigation =
                          NavigationTabs(NavTab.LoginDni);
                    },
                    child: Icon(
                      Icons.close,
                      size: 50,
                      color: AppColors.PrimaryWhite,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 50),
          Text("Registra tus datos",
              style: AppTextStyle.whiteStyle(fontSize: AppFontSizes.title36)),
          SizedBox(height: 40),
          SizedBox(
            height: 180,
            width: 180,
            child: GestureDetector(
              onTap: selectImage,
              child: Stack(children: <Widget>[
                processingPhoto
                    ? _buildProcessingImage()
                    : (_image != null ? _buildImage() : _buildPlaceholder()),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: AppColors.MountbattenPink,
                      shape: BoxShape.circle,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: AppColors.PrimaryBlack.withAlpha(50),
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.edit,
                        color: AppColors.PrimaryWhite,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ),
          SizedBox(height: 20),
          Text("Sube tu foto",
              style: AppTextStyle.whiteStyle(fontSize: AppFontSizes.title18)),
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
                  hintText: "Ingresa tu dni aquí...",
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
              onPressed: enrollUser,
              child: Center(
                child: Text(
                  "Guardar",
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
    return Container(
      height: 180,
      width: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: FileImage(_image),
          fit: BoxFit.fill,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.PrimaryBlack.withAlpha(50),
            offset: Offset(2.0, 2.0),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 180,
      width: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.ShadowBlue,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.PrimaryBlack.withAlpha(50),
            offset: Offset(2.0, 2.0),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.person,
          color: AppColors.PrimaryWhite,
          size: 100,
        ),
      ),
    );
  }

  Widget _buildProcessingImage() {
    return Container(
      height: 180,
      width: 180,
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.ShadowBlue,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.PrimaryBlack.withAlpha(50),
            offset: Offset(2.0, 2.0),
          ),
        ],
      ),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
