import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String uid;
  String email;
  String fullName;
  Timestamp createdAt;
  String gangId;
  List<String> savedPosts;
  String profileImageUrl;
  String gangJoinRequest;

  UserModel(
      {this.uid,
      this.email,
      this.fullName,
      this.createdAt,
      this.gangId,
      this.savedPosts,
      this.profileImageUrl,
      this.gangJoinRequest});

  UserModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    this.uid = doc.id;
    this.email = doc.data()['email'];
    this.fullName = doc.data()['fullname'];
    this.createdAt = doc.data()['createdAt'];
    this.gangId = doc.data()['gangId'];
    this.savedPosts = List<String>.from(doc.data()['savedPosts'] ?? []);
    this.profileImageUrl = doc.data()['profileImageUrl'];
    this.gangJoinRequest = doc.data()['gangJoinRequest'];
  }

  String nameAndIdJson() {
    return json.encode({
      'name': this.fullName,
      'uid': this.uid,
    });
  }
}
