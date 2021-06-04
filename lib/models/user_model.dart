import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String uid;
  String email;
  String fullName;
  Timestamp createdAt;
  String gangId;
  List<String> savedPosts;

  UserModel(
      {this.uid,
      this.email,
      this.fullName,
      this.createdAt,
      this.gangId,
      this.savedPosts});

  UserModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    this.uid = doc.id;
    this.email = doc.data()['email'];
    this.fullName = doc.data()['fullname'];
    this.createdAt = doc.data()['createdAt'];
    this.gangId = doc.data()['gangId'];
    this.savedPosts = List<String>.from(doc.data()['savedPosts']);
  }
}
