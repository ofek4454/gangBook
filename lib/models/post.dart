import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  String id;
  String authorName;
  String authorId;
  String content;
  List<PostComment> comments;
  List<PostLike> likes;
  List<String> images;
  List<String> videos;
  Timestamp createdAt;

  Post({
    this.id,
    this.authorName,
    this.authorId,
    this.comments,
    this.content,
    this.images,
    this.likes,
    this.createdAt,
    this.videos,
  });
}

class PostComment {
  String uid;
  String name;
  String comment;
  Timestamp createdAt;

  PostComment({this.uid, this.name, this.comment, this.createdAt});
}

class PostLike {
  String uid;
  String name;
  Timestamp createdAt;

  PostLike(this.uid, this.name, this.createdAt);
}
