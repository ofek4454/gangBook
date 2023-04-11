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
  String authorImage;

  Post(
      {this.id,
      this.authorName,
      this.authorId,
      this.comments,
      this.content,
      this.images,
      this.likes,
      this.createdAt,
      this.videos,
      this.authorImage});

  Post.fromDocumentSnapshot(DocumentSnapshot doc, List<PostComment> _comments) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    this.id = doc.id;
    this.authorId = data['authorId'];
    this.authorName = data['authorName'];
    this.comments = _comments;
    this.content = data['content'];
    this.createdAt = data['createdAt'];
    this.images = List<String>.from(data['images']);
    this.videos = List<String>.from(data['videos']);
    this.likes = List<String>.from(data['likes'])
        .map<PostLike>((like) => PostLike.fromJson(like))
        .toList();
    this.authorImage = data['authorImage'];
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
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    this.commetId = doc.id;
    this.comment = data['comment'];
    this.uid = data['uid'];
    this.likes = List<String>.from(data['likes'] ?? [])
        .map<PostLike>((like) => PostLike.fromJson(like))
        .toList();
    this.name = data['name'];
    this.createdAt = data['createdAt'];
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
