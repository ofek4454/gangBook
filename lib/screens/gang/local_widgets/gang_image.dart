import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gangbook/state_managment/gang_state.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class GangImage extends StatelessWidget {
  final double picRadius;

  GangImage(this.picRadius);

  Future<File> chooseImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedImage = await showDialog<PickedFile>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Choose image source'),
        actions: [
          TextButton.icon(
            icon: Icon(Icons.photo_library),
            label: Text('Gallery'),
            onPressed: () async {
              final photo = await picker.getImage(source: ImageSource.gallery);
              Navigator.of(ctx).pop(photo);
            },
          ),
          TextButton.icon(
            icon: Icon(Icons.camera_alt),
            label: Text('Camera'),
            onPressed: () async {
              final photo = await picker.getImage(source: ImageSource.camera);
              Navigator.of(ctx).pop(photo);
            },
          )
        ],
      ),
    );

    if (pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No image selected please try again'),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
      return null;
    }
    return File(pickedImage.path);
  }

  @override
  Widget build(BuildContext context) {
    final GangState gangState = Provider.of<GangState>(context);
    bool isLoading = false;
    bool isEditing = false;
    File selectedImage;
    double bottomMargin = picRadius * 0.55;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: bottomMargin),
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          ClipPath(
            clipper: CustomShapeClipper(),
            child: Container(
              color: Theme.of(context).secondaryHeaderColor,
            ),
          ),
          StatefulBuilder(
            builder: (context, setState) {
              return Positioned(
                bottom: picRadius * 0.2,
                child: ClipOval(
                  child: Container(
                    width: picRadius * 2,
                    height: picRadius * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        gangState?.gang?.gangImage == null &&
                                selectedImage == null
                            ? Image.asset(
                                'assets/images/gang_placeholder.jpg',
                                fit: BoxFit.cover,
                                height: double.infinity,
                                width: double.infinity,
                              )
                            : selectedImage == null
                                ? FadeInImage(
                                    placeholder: AssetImage(
                                        'assets/images/gang_placeholder.jpg'),
                                    image: CachedNetworkImageProvider(
                                        gangState.gang.gangImage),
                                    fit: BoxFit.cover,
                                    height: double.infinity,
                                    width: double.infinity,
                                  )
                                : Image.file(
                                    selectedImage,
                                    fit: BoxFit.cover,
                                    height: double.infinity,
                                    width: double.infinity,
                                  ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              if (isEditing) {
                                setState(() {
                                  isLoading = true;
                                });
                                await gangState.changeGangImage(selectedImage);
                                setState(() {
                                  isLoading = false;
                                });
                              } else {
                                selectedImage = await chooseImage(context);
                                setState(() {
                                  isEditing = !isEditing;
                                });
                              }
                            },
                            splashColor: Theme.of(context).secondaryHeaderColor,
                            child: Container(
                              color: Colors.white54,
                              height: picRadius * 0.4,
                              width: double.infinity,
                              alignment: Alignment.center,
                              child: FittedBox(
                                child: isEditing
                                    ? Text(
                                        'Save',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      )
                                    : Text(
                                        'Edit',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                        if (isLoading)
                          Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  Theme.of(context).hintColor.withOpacity(0.25),
                            ),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}

class CustomShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final height = size.height * 0.9;
    var path = Path();
    path.lineTo(0.0, height * 0.65);
    path.quadraticBezierTo(size.width / 2, height, size.width, height * 0.65);
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
