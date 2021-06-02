import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gangbook/models/post_model.dart';
import 'package:gangbook/models/user_model.dart';
import 'package:gangbook/services/posts_db.dart';

class PostState extends ChangeNotifier {
  final Post _post;
  final UserModel user;
  final String gangId;

  PostState(Post post, this.user, this.gangId) : _post = post;

  Post get post => _post;

  void likePost() async {
    final postLike = PostLike(
      uid: user.uid,
      name: user.fullName,
      createdAt: Timestamp.now(),
    );
    _post.likes.add(postLike);
    notifyListeners();
    final res = await PostsDB().likePost(gangId, _post.id, postLike);
    if (res == 'error') {
      post.likes.remove(postLike);
      notifyListeners();
    }
  }

  void likeComment(
      Post post, PostComment comment, String uid, String name) async {
    final postLike = PostLike(
      uid: uid,
      name: name,
      createdAt: Timestamp.now(),
    );
    comment.likes.add(postLike);
    notifyListeners();
    final res = await PostsDB().likeComment(gangId, post.id, comment, postLike);
    if (res == 'error') {
      post.likes.remove(postLike);
      notifyListeners();
    }
  }

  void commentsOnPost(String comment) async {
    final postComment = PostComment(
      uid: user.uid,
      name: user.fullName,
      comment: comment,
      createdAt: Timestamp.now(),
    );
    post.comments.add(postComment);
    notifyListeners();
    final res = await PostsDB().commentOnPost(gangId, post.id, postComment);
    if (res == 'error') {
      post.comments.remove(postComment);
      notifyListeners();
    }
  }

  void unLikePost() async {
    final likeToRemove = _post.likes.firstWhere((like) => like.uid == user.uid);
    post.likes.remove(likeToRemove);
    notifyListeners();
    final res = await PostsDB().unLikePost(gangId, post.id, likeToRemove);
    if (res == 'error') {
      post.likes.add(likeToRemove);
      notifyListeners();
    }
  }

  void unLikeComment(Post post, PostComment comment, String uid) async {
    final likeToRemove = comment.likes.firstWhere((like) => like.uid == uid);
    comment.likes.remove(likeToRemove);
    notifyListeners();
    final res =
        await PostsDB().unLikeComment(gangId, post.id, comment, likeToRemove);
    if (res == 'error') {
      post.likes.add(likeToRemove);
      notifyListeners();
    }
  }
}
