import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gangbook/models/gang_member.dart';

class GangModel {
  String id;
  String name;
  String leader;
  List<GangMember> members;
  Timestamp createdAt;
  List<String> meetIds;
  List<String> joinRequests;
  String gangImage;
  bool isPrivate;

  GangModel(
      {this.id,
      this.name,
      this.leader,
      this.members,
      this.createdAt,
      this.meetIds,
      this.isPrivate,
      this.joinRequests,
      this.gangImage});

  GangModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    this.id = doc.id;
    this.name = data['name'];
    this.leader = data['leader'];
    this.members = List<String>.from(data['members'])
        .map<GangMember>((member) => GangMember.fromJson(member))
        .toList();
    this.createdAt = data['createdAt'];
    this.meetIds = List<String>.from(data['meetIds']);
    this.isPrivate = data['isPrivate'] ?? false;
    this.joinRequests = List<String>.from(data['joinRequests'] ?? []);
    this.gangImage = data['gangImage'];
  }
}
