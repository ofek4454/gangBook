import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  String uid;
  String email;
  String fullName;
  Timestamp createdAt;
  String gangId;

  AppUser({
    this.uid,
    this.email,
    this.fullName,
    this.createdAt,
    this.gangId,
  });
}
