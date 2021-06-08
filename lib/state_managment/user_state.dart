import 'dart:io';

import 'package:gangbook/models/user_model.dart';
import 'package:gangbook/services/cloudinary_requests.dart';
import 'package:gangbook/services/user_db.dart';

class UserState {
  UserModel _user;

  UserState(this._user);

  UserModel get user => _user;

  bool isPostSaved(String postId) {
    return _user.savedPosts.contains(postId);
  }

  void savePost(String postId) async {
    await UserDB().savePost(_user.uid, postId);
  }

  void unSavePost(String postId) async {
    await UserDB().unSavePost(_user.uid, postId);
  }

  Future<void> changeProfileImage(File image) async {
    final imageUrl =
        await CloudinaryRequests().uploadUserProfileImage(image, _user.uid);

    await UserDB().updateProfileImage(_user.uid, imageUrl);
  }
}
