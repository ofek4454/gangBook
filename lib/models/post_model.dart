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
  String commetId;
  String uid;
  String name;
  String comment;
  List<PostLike> likes;
  Timestamp createdAt;

  PostComment(
      {this.uid,
      this.name,
      this.comment,
      this.createdAt,
      this.likes,
      this.commetId});

  PostComment.fromDocumentSnapshot(DocumentSnapshot doc) {
    this.commetId = doc.id;
    this.comment = doc.data()['comment'];
    this.uid = doc.data()['uid'];
    this.likes = List<String>.from(doc.data()['likes'])
        .map<PostLike>((like) => PostLike.fromJson(like))
        .toList();
    this.name = doc.data()['name'];
    this.createdAt = doc.data()['createdAt'];
  }

  bool doILike(String uid) {
    bool retVal = false;
    try {
      this.likes.firstWhere((like) => like.uid == uid);
      retVal = true;
    } catch (e) {}
    return retVal;
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
