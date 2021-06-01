import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gangbook/models/event_member.dart';

class MeetModel {
  String id;
  String title;
  String location;
  Timestamp meetingAt;
  Timestamp createdAt;
  String moreInfo;
  List<EventMember> membersAreComming;

  MeetModel({
    this.id,
    this.title,
    this.location,
    this.meetingAt,
    this.createdAt,
    this.moreInfo,
    this.membersAreComming,
  });

  MeetModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    this.id = doc.id;
    this.title = doc.data()['title'];
    this.location = doc.data()['location'];
    this.moreInfo = doc.data()['moreInfo'];
    this.meetingAt = doc.data()['meetingAt'];
    this.createdAt = doc.data()['createdAt'];
    this.membersAreComming = List<String>.from(doc.data()['membersAreComming'])
        .map<EventMember>((evData) => EventMember.fromJson(evData))
        .toList();
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
