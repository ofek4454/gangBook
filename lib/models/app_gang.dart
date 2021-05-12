import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gangbook/models/gang_member.dart';
import 'package:gangbook/models/post.dart';

class AppGang {
  String id;
  String name;
  String leader;
  List<GangMember> members;
  Timestamp createdAt;
  List<String> meetIds;
  List<Post> posts;

  AppGang({
    this.id,
    this.name,
    this.leader,
    this.members,
    this.createdAt,
    this.meetIds,
    this.posts,
  });
}
