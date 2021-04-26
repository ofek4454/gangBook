import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gangbook/models/gang_member.dart';

class AppGang {
  String id;
  String name;
  String leader;
  List<GangMember> members;
  Timestamp createdAt;
  String meetId;

  AppGang({
    this.id,
    this.name,
    this.leader,
    this.members,
    this.createdAt,
    this.meetId,
  });
}