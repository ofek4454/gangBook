import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gangbook/models/event_member.dart';

class Meet {
  String id;
  String title;
  String location;
  Timestamp meetingAt;
  Timestamp createdAt;
  String moreInfo;
  List<EventMember> membersAreComming;

  Meet({
    this.id,
    this.title,
    this.location,
    this.meetingAt,
    this.createdAt,
    this.moreInfo,
    this.membersAreComming,
  });

  ConfirmationType userAreComming(String uid) {
    final user =
        membersAreComming.firstWhere((eventMember) => eventMember.uid == uid);
    return user.isComming;
  }
}
