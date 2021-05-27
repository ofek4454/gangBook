import 'dart:convert';

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

  bool doILike(String uid) {
    bool retVal = false;
    try {
      this.likes.firstWhere((like) => like.uid == uid);
      retVal = true;
    } catch (e) {}
    return retVal;
  }
}

class PostComment {
  String uid;
  String name;
  String comment;
  Timestamp createdAt;

  PostComment({this.uid, this.name, this.comment, this.createdAt});

  factory PostComment.fromJson(String data) {
    final _data = json.decode(data);
    return PostComment(
      uid: _data['uid'],
      comment: _data['comment'],
      name: _data['name'],
      createdAt: Timestamp.fromDate(DateTime.parse(_data['createdAt'])),
    );
  }

  String toJson() {
    return json.encode({
      'uid': this.uid,
      'name': this.name,
      'comment': this.comment,
      'createdAt': this.createdAt.toDate().toIso8601String(),
    });
  }
}

class PostLike {
  String uid;
  String name;
  Timestamp createdAt;

  PostLike({this.uid, this.name, this.createdAt});

  factory PostLike.fromJson(String data) {
    final _data = json.decode(data);
    return PostLike(
      uid: _data['uid'],
      name: _data['name'],
      createdAt: Timestamp.fromDate(DateTime.parse(_data['createdAt'])),
    );
  }

  String toJson() {
    return json.encode({
      'uid': this.uid,
      'name': this.name,
      'createdAt': this.createdAt.toDate().toIso8601String(),
    });
  }
}
