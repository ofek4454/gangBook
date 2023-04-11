import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gangbook/models/event_member.dart';
import 'package:gangbook/models/gang_member.dart';

class MeetModel {
  String id;
  String title;
  String location;
  Timestamp meetingAt;
  Timestamp createdAt;
  String moreInfo;
  List<EventMember> membersAreComming;
  GangMember createBy;

  MeetModel({
    this.id,
    this.title,
    this.location,
    this.meetingAt,
    this.createdAt,
    this.moreInfo,
    this.membersAreComming,
    this.createBy,
  });

  MeetModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    this.id = doc.id;
    this.title = data['title'];
    this.location = data['location'];
    this.moreInfo = data['moreInfo'];
    this.meetingAt = data['meetingAt'];
    this.createdAt = data['createdAt'];
    this.membersAreComming = List<String>.from(data['membersAreComming'])
        .map<EventMember>((evData) => EventMember.fromJson(evData))
        .toList();
    this.createBy = GangMember.fromJson(data['createBy']);
  }

  ConfirmationType userAreComming(String uid) {
    final user =
        membersAreComming.firstWhere((eventMember) => eventMember.uid == uid);
    return user.isComming;
  }

  EventMember eventMemberById(String uid) {
    final EventMember eventMember =
        this.membersAreComming.firstWhere((member) => member.uid == uid);
    return eventMember;
  }
}
