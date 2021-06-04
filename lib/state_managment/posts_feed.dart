import 'package:flutter/material.dart';
import 'package:gangbook/models/post_model.dart';
import 'package:gangbook/services/posts_db.dart';

class PostsFeed extends ChangeNotifier {
  List<Post> _posts;

  List<Post> get posts => _posts;

  Future<void> loadPosts(String gangId) async {
    try {
      _posts = await PostsDB().loadPosts(gangId);
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
