import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gangbook/state_managment/current_user.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

enum PostType {
  Privete,
  Public,
}

class UploadPostField extends StatefulWidget {
  @override
  _UploadPostFieldState createState() => _UploadPostFieldState();
}

class _UploadPostFieldState extends State<UploadPostField> {
  final textController = TextEditingController();

  List<File> images = [];

  PostType postType = PostType.Public;

  String nameInitials(String fullName) {
    final splittedName = fullName.split(' ');
    return splittedName[0][0] + splittedName[1][0];
  }

  Future<void> addImage(BuildContext context) async {
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
      return;
    }
    setState(() {
      images.add(File(pickedImage.path));
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final fieldHeight = screenSize.height * 0.15;
    final user = Provider.of<CurrentUser>(context, listen: false).user;

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: fieldHeight * 0.25,
                  child: Text(nameInitials(user.fullName).toUpperCase()),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      height: fieldHeight * 0.4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.grey[300],
                      ),
                      child: TextField(
                        controller: textController,
                        minLines: 1,
                        maxLines: 3,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          hintText: 'What would you like to post?',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (images.isNotEmpty) SizedBox(height: 10),
            if (images.isNotEmpty)
              Container(
                height: screenSize.width * 0.32,
                child: ListView.builder(
                  itemCount: images.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) => Dismissible(
                    key: GlobalKey(),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                      ),
                    ),
                    direction: DismissDirection.down,
                    onDismissed: (direction) => setState(() {
                      images.remove(images[index]);
                    }),
                    child: Image.file(
                      images[index],
                      width: screenSize.width * 0.3,
                      height: screenSize.width * 0.3,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton(
                  onChanged: (PostType val) {
                    setState(() {
                      postType = val;
                    });
                  },
                  value: postType,
                  items: [
                    DropdownMenuItem(
                      value: PostType.Public,
                      child: Row(
                        children: [
                          Text('Public'),
                          Icon(Icons.public),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: PostType.Privete,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Private',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Icon(
                            Icons.lock_outline,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                FlatButton.icon(
                  minWidth: 0,
                  icon: Icon(Icons.photo_library),
                  label: Text('Add image'),
                  onPressed: () => addImage(context),
                  textColor: Theme.of(context).secondaryHeaderColor,
                ),
                FlatButton(
                  minWidth: 0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Post',
                        style: TextStyle(
                            color: Theme.of(context).primaryColorDark),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Theme.of(context).primaryColorDark,
                      ),
                    ],
                  ),
                  onPressed: () => () {}, //_post(context),
                  splashColor:
                      Theme.of(context).primaryColorDark.withOpacity(0.3),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
