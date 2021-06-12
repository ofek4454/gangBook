import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gangbook/models/user_model.dart';
import 'package:gangbook/services/posts_db.dart';
import 'package:gangbook/state_managment/posts_feed.dart';
import 'package:gangbook/state_managment/user_state.dart';
import 'package:gangbook/utils/names_initials.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

enum PostType {
  Privete,
  Public,
}

class UploadPostField extends StatefulWidget {
  UploadPostField();
  @override
  _UploadPostFieldState createState() => _UploadPostFieldState();
}

class _UploadPostFieldState extends State<UploadPostField> {
  final textController = TextEditingController();
  bool isLoading = false;

  List<File> images = [];
  List<File> videos = [];

  PostType postType = PostType.Public;

  Future<void> addImage() async {
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

  Future<void> addVideo() async {
    final picker = ImagePicker();
    final pickedVideo = await showDialog<PickedFile>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Choose video source'),
        actions: [
          FlatButton.icon(
            icon: Icon(Icons.photo_library),
            label: Text('Gallery'),
            onPressed: () async {
              final video = await picker.getVideo(
                source: ImageSource.gallery,
                maxDuration: Duration(minutes: 5),
              );
              Navigator.of(ctx).pop(video);
            },
          ),
          FlatButton.icon(
            icon: Icon(Icons.camera_alt),
            label: Text('Camera'),
            onPressed: () async {
              final video = await picker.getVideo(
                source: ImageSource.camera,
                maxDuration: Duration(minutes: 5),
              );
              Navigator.of(ctx).pop(video);
            },
          )
        ],
      ),
    );

    if (pickedVideo == null) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('No video selected please try again'),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
      return;
    }
    final video = File(pickedVideo.path);
    final controller = VideoPlayerController.file(video);
    await controller.initialize();
    controller.setLooping(true);
    controller.setVolume(0.0);

    setState(() {
      videos.add(video);
      videoControllers.add(controller);
      controller.play();
    });
  }

  Future<void> _post() async {
    if (textController.text.isEmpty && images.isEmpty && videos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nothing to post'),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
      return;
    }
    setState(() {
      isLoading = true;
    });
    final user = Provider.of<UserState>(context, listen: false).user;

    try {
      FocusScope.of(context).unfocus();
      final post = await PostsDB().uploadPost(
        user.gangId,
        user.fullName,
        user.uid,
        textController.text,
        images,
        videos,
        user.profileImageUrl,
      );
      if (post == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Something went wrong! please try again'),
            backgroundColor: Theme.of(context).errorColor,
          ),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }
      Provider.of<PostsFeed>(context, listen: false).uploadPost(post);
      textController.clear();
      images = [];
      videos = [];
    } catch (e) {
      print(e);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final fieldHeight = screenSize.height * 0.15;
    final user = Provider.of<UserState>(context, listen: false).user;

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
                  backgroundImage: user.profileImageUrl == null
                      ? null
                      : NetworkImage(user.profileImageUrl),
                  backgroundColor: Theme.of(context).canvasColor,
                  radius: fieldHeight * 0.25,
                  child: user.profileImageUrl != null
                      ? null
                      : Text(
                          NameInitials().getInitials(user.fullName),
                          style: TextStyle(
                            color: Theme.of(context).secondaryHeaderColor,
                            fontSize: MediaQuery.of(context).size.width * 0.07,
                          ),
                        ),
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
            if (images.isNotEmpty) buildImagesPreview(screenSize),
            if (videos.isNotEmpty) SizedBox(height: 10),
            if (videos.isNotEmpty) buildVideosPreview(screenSize),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FlatButton.icon(
                  minWidth: 0,
                  icon: Icon(Icons.photo_library),
                  label: Text('Add image'),
                  onPressed: () => addImage(),
                  textColor: Theme.of(context).secondaryHeaderColor,
                ),
                FlatButton.icon(
                  minWidth: 0,
                  icon: Icon(Icons.videocam),
                  label: Text('Add video'),
                  onPressed: () => addVideo(),
                  textColor: Theme.of(context).secondaryHeaderColor,
                ),
                isLoading
                    ? CircularProgressIndicator.adaptive()
                    : FlatButton(
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
                        onPressed: () => _post(),
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

  Widget buildImagesPreview(Size screenSize) {
    return Container(
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
            images.removeAt(index);
          }),
          child: Image.file(
            images[index],
            width: screenSize.width * 0.3,
            height: screenSize.width * 0.3,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  List<VideoPlayerController> videoControllers = [];

  Widget buildVideosPreview(Size screenSize) {
    return Container(
      height: screenSize.width * 0.32,
      child: ListView.builder(
        itemCount: videos.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) => SizedBox(
          width: screenSize.width * 0.3,
          height: screenSize.width * 0.3,
          child: Dismissible(
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
              videos.removeAt(index);
              videoControllers[index].dispose();
              videoControllers.removeAt(index);
            }),
            child: VideoPlayer(videoControllers[index]),
          ),
        ),
      ),
    );
  }
}
