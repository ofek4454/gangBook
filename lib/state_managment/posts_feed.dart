import 'package:flutter/material.dart';
import 'package:gangbook/models/post_model.dart';
import 'package:gangbook/services/posts_db.dart';

class PostsFeed extends ChangeNotifier {
  List<Post> _posts;

  List<Post> get posts => _posts;

  Future<void> loadAllPosts(String gangId) async {
    try {
      _posts = await PostsDB().loadAllPosts(gangId);
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> loadUsersPosts(String gangId, String uid) async {
    try {
      _posts = await PostsDB().loadUsersPosts(gangId, uid);
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> loadSavedPosts(
      String gangId, String uid, List<String> savedPosts) async {
    try {
      _posts = await PostsDB().loadSavedPosts(gangId, uid, savedPosts);
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  void uploadPost(Post post) {
    _posts.insert(0, post);
    notifyListeners();
  }

  void deletePost(String postId, String gangId) async {
    _posts.removeWhere((post) => post.id == postId);
    notifyListeners();
    await PostsDB().deletePost(gangId, postId);
  }
}
