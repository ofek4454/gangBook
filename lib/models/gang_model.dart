import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gangbook/models/gang_member.dart';

class GangModel {
  String id;
  String name;
  String leader;
  List<GangMember> members;
  Timestamp createdAt;
  List<String> meetIds;

  GangModel({
    this.id,
    this.name,
    this.leader,
    this.members,
    this.createdAt,
    this.meetIds,
  });

  GangModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    this.id = doc.id;
    this.name = doc.data()['name'];
    this.leader = doc.data()['leader'];
    this.members = List<String>.from(doc.data()['members'])
        .map<GangMember>((member) => GangMember.fromJson(member))
        .toList();
    this.createdAt = doc.data()['createdAt'];
    this.meetIds = List<String>.from(doc.data()['meetIds']);
  }
}