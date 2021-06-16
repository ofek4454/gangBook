import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gangbook/state_managment/user_state.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfileImageAndBG extends StatelessWidget {
  final String imageUrl;
  final double picRadius;
  final bool isEditable;

  ProfileImageAndBG(this.picRadius, {this.imageUrl, this.isEditable = true});

  Future<File> chooseImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedImage = await showDialog<PickedFile>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Choose image source'),
        actions: [
          FlatButton.icon(
            icon: Icon(Icons.photo_library),
            label: Text('Gallery'),
            onPressed: () async {
              final photo = await picker.getImage(source: ImageSource.gallery);
              Navigator.of(ctx).pop(photo);
            },
          ),
          FlatButton.icon(
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
      Scaffold.of(context).showSnackBar(
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
    final UserState userState =
        isEditable ? Provider.of<UserState>(context) : null;
    bool isLoading = false;
    bool isEditing = false;
    File selectedImage;
    double bottomMargin = isEditable ? picRadius * 0.55 : 0;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: bottomMargin),
      child: Stack(
        alignment: Alignment.bottomCenter,
        overflow: Overflow.visible,
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
                        userState?.user?.profileImageUrl == null &&
                                selectedImage == null
                            ? Image.asset(
                                'assets/images/person_placeholder.png',
                                fit: BoxFit.cover,
                                height: double.infinity,
                                width: double.infinity,
                              )
                            : selectedImage == null
                                ? FadeInImage(
                                    placeholder: AssetImage(
                                        'assets/images/person_placeholder.png'),
                                    image: CachedNetworkImageProvider(
                                        userState.user.profileImageUrl),
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
                        if (isEditable)
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                if (isEditing) {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  await Provider.of<UserState>(context,
                                          listen: false)
                                      .changeProfileImage(selectedImage);
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
                              splashColor:
                                  Theme.of(context).secondaryHeaderColor,
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
